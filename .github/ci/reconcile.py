"""Diagnose open PRs and reconcile policy checks, approvals and auto-merge."""

import argparse
import base64
import json
import os
import re
import subprocess
from pathlib import Path
from urllib.parse import quote

from branches import api
from merge_policy import (
    BOT,
    build_blockers,
    eligible,
    protection_ready,
    queue_members,
    routine_update,
)
from policy import load_policy
from update import compare

REQUIRED = {
    "nixbot/nix-build": 4016365,
    "nixbot/nix-eval": 4016365,
    "automation-tests": 15368,
    "package-quality": 15368,
}


def pages(endpoint, key=None):
    result = subprocess.run(
        ["gh", "api", "--paginate", "--slurp", endpoint],
        check=True,
        text=True,
        capture_output=True,
    )
    return [
        item
        for page in json.loads(result.stdout)
        for item in (page[key] if key else page)
    ]


def query(text, variables):
    return api("graphql", {"query": text, "variables": variables})["data"]


def content(repo, path, sha):
    result = api(f"repos/{repo}/contents/{quote(path, safe='/')}?ref={sha}")
    if result.get("encoding") != "base64" or result["type"] != "file":
        raise ValueError(f"Cannot inspect regular file {path}")
    return base64.b64decode(result["content"]).decode()


def inspect(repo, number, policy):
    pr = api(f"repos/{repo}/pulls/{number}")
    head = pr["head"]["sha"]
    owner, name = repo.split("/")
    review = query(
        """query($owner:String!, $name:String!, $number:Int!) {
      repository(owner:$owner,name:$name) { pullRequest(number:$number) {
        id reviewDecision reviewThreads(first:100) { nodes { isResolved } pageInfo { hasNextPage } }
      } }
    }""",
        {"owner": owner, "name": name, "number": number},
    )["repository"]["pullRequest"]
    pr["node_id"] = review["id"]
    pr["reviewDecision"] = review["reviewDecision"]
    if review["reviewThreads"]["pageInfo"]["hasNextPage"]:
        raise ValueError("Too many review threads to establish eligibility")
    unresolved = any(not t["isResolved"] for t in review["reviewThreads"]["nodes"])
    latest = {}
    for r in pages(f"repos/{repo}/pulls/{number}/reviews?per_page=100"):
        if r["state"] != "COMMENTED":
            latest[r["user"]["login"]] = r
    human = False
    for login, r in latest.items():
        if (
            r["user"]["type"] != "User"
            or r["state"] != "APPROVED"
            or r["commit_id"] != head
        ):
            continue
        permission = api(f"repos/{repo}/collaborators/{quote(login)}/permission")[
            "permission"
        ]
        if permission in {"admin", "maintain", "write"}:
            human = True
    commits = pages(f"repos/{repo}/pulls/{number}/commits?per_page=100")
    if len(commits) != pr["commits"]:
        raise ValueError("Cannot inspect every commit signature")
    signed = bool(commits) and all(
        c["commit"]["verification"]["verified"] for c in commits
    )
    changed = pages(f"repos/{repo}/pulls/{number}/files?per_page=100")
    if len(changed) != pr["changed_files"]:
        raise ValueError("Cannot inspect the complete PR diff")
    files = {}
    routine = False
    if (
        not human
        and pr["user"]["login"] == BOT
        and changed
        and all(f["status"] == "modified" for f in changed)
    ):
        for f in changed:
            path = f["filename"]
            if not (path.endswith(".nix") or path in {"flake.lock", "README.md"}):
                break
            files[path] = (
                content(repo, path, pr["base"]["sha"]),
                content(repo, path, head),
            )
        if len(files) == len(changed):
            routine = routine_update(pr, files, policy, compare)
    allowed, reason = eligible(pr, routine, human, signed, unresolved)
    checks = pages(f"repos/{repo}/commits/{head}/check-runs?per_page=100", "check_runs")
    blockers = build_blockers(checks, REQUIRED)
    newest = {}
    for check in checks:
        key = (check["name"], check["app"]["id"])
        if key not in newest or check["id"] > newest[key]["id"]:
            newest[key] = check
    blockers.extend(
        f"[{c['name']}]({c['details_url']}): failure"
        for c in newest.values()
        if c["app"]["id"] == 4016365
        and c["name"].startswith("nixbot/nix-build ")
        and c["conclusion"] == "failure"
    )
    if pr.get("mergeable") is not True:
        blockers.append("Mergeability is unknown or conflicts remain")
    if api(f"repos/{repo}/pulls/{number}")["head"]["sha"] != head:
        raise ValueError("PR head changed while inspecting; retry on the new revision")
    return pr, allowed, reason, blockers, routine


def report_check(repo, sha, allowed, reason):
    return api(
        f"repos/{repo}/check-runs",
        {
            "name": "update-policy",
            "head_sha": sha,
            "status": "completed",
            "conclusion": "success" if allowed else "failure",
            "output": {"title": "Update policy", "summary": reason},
        },
    )


def enable_merge(pr, repo):
    # The expected SHA prevents approval/queue actions from following a racing push.
    query(
        """mutation($input: EnablePullRequestAutoMergeInput!) {
      enablePullRequestAutoMerge(input:$input) { clientMutationId }
    }""",
        {
            "input": {
                "pullRequestId": pr["node_id"],
                "expectedHeadOid": pr["head"]["sha"],
                "mergeMethod": "SQUASH",
            }
        },
    )


def reconcile(repo, number, policy, apply=False, merge=False):
    pr, allowed, reason, blockers, routine = inspect(repo, number, policy)
    summary = f"[#{number}](https://github.com/{repo}/pull/{number}): {reason}"
    if blockers:
        summary += "; " + "; ".join(blockers)
    if apply:
        report_check(repo, pr["head"]["sha"], allowed, reason)
        if not allowed and pr.get("auto_merge"):
            query(
                "mutation($id:ID!){disablePullRequestAutoMerge(input:{pullRequestId:$id}){clientMutationId}}",
                {"id": pr["node_id"]},
            )
        protected = (
            protection_ready(
                api(f"repos/{repo}/rules/branches/main"),
                {**REQUIRED, "update-policy": 15368},
            )
            if merge
            else False
        )
        if merge and not protected:
            summary += "; activation blocked: configure all required checks with their App IDs in the main ruleset"
        if allowed and not blockers and merge and protected:
            if routine:
                reviews = pages(f"repos/{repo}/pulls/{number}/reviews?per_page=100")
                if not any(
                    r["user"]["login"] == "github-actions[bot]"
                    and r["state"] == "APPROVED"
                    and r["commit_id"] == pr["head"]["sha"]
                    for r in reviews
                ):
                    api(
                        f"repos/{repo}/pulls/{number}/reviews",
                        {
                            "event": "APPROVE",
                            "commit_id": pr["head"]["sha"],
                            "body": "Routine update policy and required checks passed for this commit.",
                        },
                    )
            if not pr.get("auto_merge"):
                enable_merge(pr, repo)
    return summary


def check_group(repo, event, policy, apply=False):
    group = event["merge_group"]
    match = re.fullmatch(
        r"refs/heads/gh-readonly-queue/main/pr-(\d+)-[0-9a-f]+", group["head_ref"]
    )
    if not match:
        raise ValueError("Unrecognised merge queue ref")
    number = int(match.group(1))
    owner, name = repo.split("/")
    queue = query(
        """query($owner:String!,$name:String!){repository(owner:$owner,name:$name){mergeQueue(branch:"main"){
      entries(first:100){nodes{position pullRequest{number headRefOid}} pageInfo{hasNextPage}}
    }}}""",
        {"owner": owner, "name": name},
    )["repository"]["mergeQueue"]
    if queue is None or queue["entries"]["pageInfo"]["hasNextPage"]:
        raise ValueError("Cannot establish complete merge queue membership")
    entries = queue["entries"]["nodes"]
    numbers = queue_members(entries, number)
    allowed = True
    reasons = []
    for member in numbers:
        pr, ok, reason, _, _ = inspect(repo, member, policy)
        expected = next(
            e["pullRequest"]["headRefOid"]
            for e in entries
            if e["pullRequest"]["number"] == member
        )
        ok = ok and pr["head"]["sha"] == expected
        allowed = allowed and ok
        reasons.append(f"#{member}: {reason}")
    # Confirm this event still describes the live synthetic queue commit.
    ref = group["head_ref"].removeprefix("refs/")
    if api(f"repos/{repo}/git/ref/{ref}")["object"]["sha"] != group["head_sha"]:
        raise ValueError("Merge group was replaced")
    reason = "\n".join(reasons)
    if apply:
        report_check(repo, group["head_sha"], allowed, reason)
    if not allowed:
        raise ValueError(reason)
    return f"Merge group {group['head_sha']}: {reason}"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=os.environ.get("GITHUB_REPOSITORY"))
    parser.add_argument("--number", type=int)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    if not args.repo:
        parser.error("--repo is required")
    policy = load_policy()
    event = (
        json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text())
        if os.environ.get("GITHUB_EVENT_PATH")
        else {}
    )
    summaries = []
    failures = []
    if "merge_group" in event:
        try:
            summaries.append(check_group(args.repo, event, policy, args.apply))
        except (
            RuntimeError,
            ValueError,
            KeyError,
            subprocess.CalledProcessError,
        ) as error:
            if args.apply:
                report_check(
                    args.repo, event["merge_group"]["head_sha"], False, str(error)
                )
            raise
    else:
        numbers = (
            [args.number]
            if args.number
            else [
                p["number"]
                for p in pages(
                    f"repos/{args.repo}/pulls?state=open&base=main&per_page=100"
                )
            ]
        )
        for number in numbers:
            try:
                summaries.append(
                    reconcile(
                        args.repo,
                        number,
                        policy,
                        args.apply,
                        os.environ.get("AUTOMATION_MERGE_ENABLED") == "true",
                    )
                )
            except (
                RuntimeError,
                ValueError,
                KeyError,
                subprocess.CalledProcessError,
            ) as error:
                failures.append(number)
                summaries.append(f"#{number}: diagnosis failed: {error}")
                if args.apply:
                    current = api(f"repos/{args.repo}/pulls/{number}")
                    report_check(
                        args.repo,
                        current["head"]["sha"],
                        False,
                        "Diagnosis incomplete; fail closed",
                    )
    text = "\n".join(f"- {s}" for s in summaries) + "\n"
    print(text)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with Path(os.environ["GITHUB_STEP_SUMMARY"]).open("a") as summary:
            summary.write(text)
    if failures:
        raise SystemExit(f"Diagnosis failed for {failures}")


if __name__ == "__main__":
    main()
