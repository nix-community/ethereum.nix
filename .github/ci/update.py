"""Update a validated package group, retaining package-specific hash procedures."""

import json
import os
import subprocess
import sys
from pathlib import Path

from policy import group_for, load_policy, nix_update_args, validate_version


def run(args):
    return subprocess.run(
        args, check=True, text=True, capture_output=True
    ).stdout.strip()


def version(name):
    return run(["nix", "eval", f".#packages.x86_64-linux.{name}.version", "--raw"])


def compare(old, new):
    # validate_version restricts versions to VERSION's alphabet before this call.
    return int(
        run(
            [
                "nix",
                "eval",
                "--json",
                "--expr",
                f"builtins.compareVersions {json.dumps(old)} {json.dumps(new)}",
            ]
        )
    )


def update_group(
    name,
    policy,
    get_version=version,
    execute=None,
    compare_versions=compare,
    root=Path("."),
):
    execute = execute or (lambda cmd: subprocess.run(cmd, check=True))
    members = group_for(name, policy)
    before = {member: get_version(member) for member in members}
    for member in members:
        directory = root / "packages" / member
        custom = next(
            (
                directory / filename
                for filename in ("update.sh", "update.py")
                if (directory / filename).exists()
            ),
            None,
        )
        command = (
            [str(custom.resolve())]
            if custom
            else ["nix-update", *nix_update_args(member, policy, root)]
        )
        execute(command)
    after = {member: get_version(member) for member in members}
    for member in members:
        validate_version(
            member, before[member], after[member], policy, compare_versions
        )
    if len(members) > 1 and len(set(after.values())) != 1:
        raise ValueError(f"Companion versions must agree: {after}")
    return after[members[0]]


def main():
    name = sys.argv[1]
    policy_path = Path(__file__).with_name("update-policy.json")
    if not policy_path.exists():
        policy_path = Path(__file__).resolve().parents[1] / "config/update-policy.json"
    policy = load_policy(policy_path)
    new_version = update_group(name, policy)
    # Limit formatting to changed files. Never include unrelated formatting drift.
    changed = run(["git", "diff", "--name-only", "-z", "HEAD"]).split("\0")
    untracked = run(["git", "ls-files", "--others", "--exclude-standard", "-z"]).split(
        "\0"
    )
    files = [p for p in sorted(set(changed + untracked)) if p and Path(p).is_file()]
    if files:
        subprocess.run(["nix", "fmt", "--", *files], check=True)
    updated = bool(run(["git", "status", "--porcelain"]))
    with Path(os.environ.get("GITHUB_OUTPUT", "/dev/stdout")).open("a") as output:
        output.write(f"updated={str(updated).lower()}\nnew_version={new_version}\n")


if __name__ == "__main__":
    main()
