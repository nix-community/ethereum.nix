"""Validated, repository-owned policy shared by discovery and update execution."""

import datetime
import json
import re
from pathlib import Path

CONFIG = Path(".github/config/update-policy.json")
NAME = re.compile(r"[a-zA-Z0-9][a-zA-Z0-9._-]*")
VERSION = re.compile(r"[0-9][a-zA-Z0-9.+_-]*")
PRERELEASE = re.compile(
    r"alpha|beta|rc|pre|preview|dev|nightly|unstable|(?<=[0-9])[ab](?=[0-9])",
    re.IGNORECASE,
)


def load_policy(path=CONFIG):
    data = json.loads(path.read_text())
    if set(data) != {"packages", "groups", "downgrades"}:
        raise ValueError("Policy must define packages, groups and downgrades")
    for name, config in data["packages"].items():
        if not NAME.fullmatch(name) or set(config) != {"channel"}:
            raise ValueError(f"Invalid package policy: {name}")
        if config["channel"] not in {"stable", "prerelease", "rolling"}:
            raise ValueError(f"Invalid channel for {name}")
    members = set()
    for primary, companions in data["groups"].items():
        for name in [primary, *companions]:
            if not NAME.fullmatch(name) or name in members:
                raise ValueError(f"Duplicate or invalid update group member: {name}")
            members.add(name)
    for exception in data["downgrades"]:
        if (
            set(exception) != {"package", "from", "to", "reason", "expires"}
            or not exception["reason"].strip()
        ):
            raise ValueError(
                "Downgrades require an exact package/from/to, reason and expiry"
            )
        datetime.date.fromisoformat(exception["expires"])
    return data


def primary_for(name, policy):
    return next((p for p, members in policy["groups"].items() if name in members), name)


def group_for(name, policy):
    primary = primary_for(name, policy)
    return [primary, *policy["groups"].get(primary, [])]


def channel_for(name, policy):
    return policy["packages"].get(name, {}).get("channel", "stable")


def validate_version(name, old, new, policy, compare, today=None):
    channel = channel_for(name, policy)
    if channel == "rolling" and old == new:
        return
    if not VERSION.fullmatch(old) or not VERSION.fullmatch(new):
        raise ValueError(f"Unrecognised version for {name}: {old!r} -> {new!r}")
    if channel == "stable" and PRERELEASE.search(new.split("+", 1)[0]):
        raise ValueError(
            f"Prerelease {new} is not allowed on the stable channel for {name}"
        )
    if compare(old, new) <= 0:
        return
    today = today or datetime.datetime.now(datetime.UTC).date()
    for exception in policy["downgrades"]:
        if (exception["package"], exception["from"], exception["to"]) == (
            name,
            old,
            new,
        ) and datetime.date.fromisoformat(exception["expires"]) >= today:
            return
    raise ValueError(f"Downgrade blocked for {name}: {old} -> {new}")


def nix_update_args(name, policy, root=Path(".")):
    path = root / "packages" / name / "nix-update-args"
    extra = (
        [
            s
            for line in path.read_text().splitlines()
            if (s := line.strip()) and not s.startswith("#")
        ]
        if path.exists()
        else []
    )
    if any(a == "--version" or a.startswith("--version=") for a in extra):
        raise ValueError(
            f"Declare the version channel in update-policy.json for {name}"
        )
    channel = channel_for(name, policy)
    return [
        "--flake",
        "--version=" + ("stable" if channel == "stable" else "unstable"),
        *extra,
        name,
    ]
