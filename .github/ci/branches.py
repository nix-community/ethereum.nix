"""Preserve update branches and append signed commits with an atomic head check."""

import argparse
import base64
import json
import os
import re
import subprocess
from pathlib import Path


def run(*args, cwd=None, check=True, input=None):
    return subprocess.run(
        args, cwd=cwd, check=check, input=input, text=True, capture_output=True
    )


def git(*args, cwd=None, check=True):
    return run(
        "git",
        "-c",
        "core.hooksPath=/dev/null",
        "-c",
        "core.fsmonitor=false",
        *args,
        cwd=cwd,
        check=check,
    )


def branch_name(kind, name):
    if not re.fullmatch(r"[a-zA-Z0-9][a-zA-Z0-9._-]*", name):
        raise ValueError(f"Invalid update name: {name!r}")
    if kind == "package":
        return f"update/{name}"
    if kind == "flake-input":
        return f"update-{name}"
    if kind == "readme":
        return "update/readme"
    raise ValueError(f"Invalid update type: {kind}")


def prepare(kind, name, cwd=None):
    """Keep the existing head intact; never reset or rebase human commits."""
    branch = branch_name(kind, name)
    if git("status", "--porcelain", cwd=cwd).stdout:
        raise ValueError("Prepare requires a clean checkout")
    git("fetch", "origin", "main", cwd=cwd)
    base = git("rev-parse", "FETCH_HEAD", cwd=cwd).stdout.strip()
    remote = git(
        "ls-remote",
        "--exit-code",
        "origin",
        f"refs/heads/{branch}",
        cwd=cwd,
        check=False,
    )
    if remote.returncode not in (0, 2):
        raise RuntimeError(f"Could not inspect remote branch: {remote.stderr}")
    exists = remote.returncode == 0
    if exists:
        git("fetch", "origin", f"refs/heads/{branch}", cwd=cwd)
        head = git("rev-parse", "FETCH_HEAD", cwd=cwd).stdout.strip()
        # This computes a merge without changing the work tree or history.
        merged = git("merge-tree", "--write-tree", head, base, cwd=cwd, check=False)
        if merged.returncode:
            raise RuntimeError(
                f"Resolve conflicts on {branch} before updating:\n{merged.stdout}"
            )
    else:
        head = base
    git("checkout", "--detach", head, cwd=cwd)
    return {
        "branch": branch,
        "head": head,
        "base": base,
        "exists": exists,
        "kind": kind,
        "name": name,
    }


def file_changes(state, cwd=None):
    """Build API file changes from the index, including untracked files/deletions."""
    git("add", "--all", cwd=cwd)
    paths = git(
        "diff", "--cached", "--name-only", "--no-renames", "-z", state["head"], cwd=cwd
    ).stdout.split("\0")
    allowed = (f"packages/{state['name']}/",)
    policy_path = Path(__file__).with_name("update-policy.json")
    if state["kind"] == "package" and policy_path.exists():
        from policy import group_for, load_policy

        allowed = tuple(
            f"packages/{name}/"
            for name in group_for(state["name"], load_policy(policy_path))
        )
    if state["kind"] == "flake-input":
        allowed = ("flake.lock",)
    elif state["kind"] == "readme":
        allowed = ("README.md",)
    changes = {"additions": [], "deletions": []}
    for path in filter(None, paths):
        if not any(
            path.startswith(p) if p.endswith("/") else path == p for p in allowed
        ):
            raise ValueError(f"Updater changed a path outside its scope: {path}")
        entry = git("ls-files", "--stage", "--", path, cwd=cwd).stdout
        if not entry:
            changes["deletions"].append({"path": path})
            continue
        mode, blob, _ = entry.split(maxsplit=2)
        old = git("ls-tree", state["head"], "--", path, cwd=cwd).stdout
        old_mode = old.split()[0] if old else "100644"
        if mode not in ("100644", "100755") or mode != old_mode:
            raise ValueError(
                f"Symlink, new executable, or mode change requires review: {path}"
            )
        # Read the staged blob, never follow a work-tree symlink.
        data = subprocess.run(
            ["git", "cat-file", "blob", blob], cwd=cwd, capture_output=True, check=True
        ).stdout
        changes["additions"].append(
            {"path": path, "contents": base64.b64encode(data).decode()}
        )
    return changes


def api(endpoint, payload=None):
    args = ["gh", "api", endpoint]
    if payload is not None:
        args += ["--input", "-"]
    response = json.loads(
        run(*args, input=json.dumps(payload) if payload is not None else None).stdout
    )
    if isinstance(response, dict) and response.get("errors"):
        raise RuntimeError(response["errors"])
    return response


def publish(state, changes, title, repo, call=api):
    """One compare-and-swap mutation appends and signs; there is no force push."""
    if not any(changes.values()):
        return state["head"]
    if not state["exists"]:
        # A racing create fails; do not adopt or overwrite that writer's branch.
        call(
            f"repos/{repo}/git/refs",
            {"ref": f"refs/heads/{state['branch']}", "sha": state["head"]},
        )
    result = call(
        "graphql",
        {
            "query": """mutation($input: CreateCommitOnBranchInput!) {
          createCommitOnBranch(input: $input) { commit { oid } }
        }""",
            "variables": {
                "input": {
                    "branch": {
                        "repositoryNameWithOwner": repo,
                        "branchName": state["branch"],
                    },
                    "expectedHeadOid": state["head"],
                    "message": {"headline": title},
                    "fileChanges": changes,
                }
            },
        },
    )
    return result["data"]["createCommitOnBranch"]["commit"]["oid"]


def ensure_pr(state, title, repo, sha):
    prs = json.loads(
        run(
            "gh",
            "pr",
            "list",
            "--repo",
            repo,
            "--head",
            state["branch"],
            "--state",
            "open",
            "--json",
            "number",
        ).stdout
    )
    if prs:
        number = str(prs[0]["number"])
        # Preserve human descriptions and titles on existing PRs.
    else:
        body = f"Automated update. Existing branch corrections are preserved.\n\nCommit: `{sha}`"
        result = api(
            f"repos/{repo}/pulls",
            {
                "title": title,
                "head": state["branch"],
                "base": "main",
                "body": body,
            },
        )
        number = str(result["number"])
        labels = [
            s.strip()
            for s in os.environ.get("PR_LABELS", "dependencies,automated").split(",")
            if s.strip()
        ]
        api(f"repos/{repo}/issues/{number}/labels", {"labels": labels})
    return number


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["prepare", "publish"])
    parser.add_argument("kind", choices=["package", "flake-input", "readme"])
    parser.add_argument("name")
    parser.add_argument("state", type=Path)
    args = parser.parse_args()
    if args.action == "prepare":
        args.state.write_text(json.dumps(prepare(args.kind, args.name)))
        return
    state = json.loads(args.state.read_text())
    changes = file_changes(state)
    if not any(changes.values()) and not state["exists"]:
        print("No content changes; no branch or PR needed.")
        return
    if args.kind == "package":
        title = f"{args.name}: {os.environ['CURRENT_VERSION']} -> {os.environ.get('NEW_VERSION') or os.environ['CURRENT_VERSION']}"
    elif args.kind == "flake-input":
        title = f"flake.lock: Update {args.name}"
    else:
        title = "README: regenerate package documentation"
    repo = os.environ["GITHUB_REPOSITORY"]
    sha = publish(state, changes, title, repo)
    print(f"Published {sha}; PR #{ensure_pr(state, title, repo, sha)}")


if __name__ == "__main__":
    main()
