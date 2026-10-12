"""Pure eligibility rules. Build success alone never authorises arbitrary edits."""

import collections
import difflib
import json
import re

from policy import group_for, validate_version

BOT = "nix-flake-auto-update[bot]"
HASH = re.compile(r"sha(?:256|512)-[A-Za-z0-9+/]+=*")
ASSIGNMENT = re.compile(
    r'\s*(version|hash|vendorHash|npmDepsHash|cargoHash|pnpmDepsHash)\s*=\s*"([^"${}\n]*)";\s*'
)


def routine_nix(old, new, name, policy, compare):
    removed, added = [], []
    for line in difflib.ndiff(old.splitlines(), new.splitlines()):
        if line.startswith("- "):
            removed.append(line[2:])
        elif line.startswith("+ "):
            added.append(line[2:])
    old_fields, new_fields = (
        collections.defaultdict(list),
        collections.defaultdict(list),
    )
    for lines, fields in [(removed, old_fields), (added, new_fields)]:
        for line in lines:
            match = ASSIGNMENT.fullmatch(line)
            if not match:
                return False
            key, value = match.groups()
            if key != "version" and not HASH.fullmatch(value):
                return False
            fields[key].append(value)
    if {k: len(v) for k, v in old_fields.items()} != {
        k: len(v) for k, v in new_fields.items()
    }:
        return False
    for old_version, new_version in zip(
        old_fields.get("version", []), new_fields.get("version", []), strict=True
    ):
        try:
            validate_version(name, old_version, new_version, policy, compare)
        except ValueError:
            return False
    return bool(added)


def routine_lock(old, new):
    before, after = json.loads(old), json.loads(new)
    if (
        set(before) != set(after)
        or before.get("root") != after.get("root")
        or before.get("version") != after.get("version")
    ):
        return False
    if set(before["nodes"]) != set(after["nodes"]):
        return False
    for name, node in before["nodes"].items():
        other = after["nodes"][name]
        if {k: v for k, v in node.items() if k != "locked"} != {
            k: v for k, v in other.items() if k != "locked"
        }:
            return False
        a, b = node.get("locked", {}), other.get("locked", {})
        if {
            k: v for k, v in a.items() if k not in {"rev", "narHash", "lastModified"}
        } != {
            k: v for k, v in b.items() if k not in {"rev", "narHash", "lastModified"}
        }:
            return False
        if a != b and (
            not re.fullmatch(r"[0-9a-f]{40}", b.get("rev", ""))
            or not HASH.fullmatch(b.get("narHash", ""))
        ):
            return False
    return before != after


def routine_update(pr, files, policy, compare):
    if (
        pr["user"]["login"] != BOT
        or pr["head"]["repo"]["full_name"] != pr["base"]["repo"]["full_name"]
    ):
        return False
    if "automated" not in {label["name"] for label in pr["labels"]} or not files:
        return False
    branch = pr["head"]["ref"]
    if branch == "update/readme":
        return set(files) == {"README.md"}
    if branch.startswith("update-"):
        return set(files) == {"flake.lock"} and routine_lock(*files["flake.lock"])
    if not branch.startswith("update/"):
        return False
    name = branch.removeprefix("update/")
    members = group_for(name, policy)
    versions = {}
    for path, (old, new) in files.items():
        parts = path.split("/")
        if (
            len(parts) != 3
            or parts[0] != "packages"
            or parts[1] not in members
            or not parts[2].endswith(".nix")
        ):
            return False
        if not routine_nix(old, new, parts[1], policy, compare):
            return False
        before = re.findall(r'^\s*version\s*=\s*"([^"]+)";', old, re.MULTILINE)
        after = re.findall(r'^\s*version\s*=\s*"([^"]+)";', new, re.MULTILINE)
        if before != after:
            if len(after) != 1:
                return False
            versions[parts[1]] = after[0]
    if len(members) > 1 and versions:
        return set(versions) == set(members) and len(set(versions.values())) == 1
    return True


def eligible(pr, routine, human_approved, signatures_valid, unresolved):
    if pr["state"] != "open" or pr["draft"] or pr["base"]["ref"] != "main":
        return False, "PR must be open, ready for review and target main"
    if "automation:manual" in {label["name"] for label in pr["labels"]}:
        return False, "Manual handling requested"
    if not signatures_valid:
        return False, "One or more commits lack a verified signature"
    if pr.get("reviewDecision") == "CHANGES_REQUESTED":
        return False, "A reviewer has requested changes"
    if unresolved:
        return False, "Review conversations remain unresolved"
    if pr.get("mergeable") is False:
        return False, "Resolve merge conflicts"
    if not routine and not human_approved:
        return False, "A maintainer must approve this revision's non-routine changes"
    return (
        True,
        "Routine update" if routine else "Current revision approved by a maintainer",
    )


def build_blockers(checks, required):
    blockers = []
    for name, app_id in required.items():
        matching = [c for c in checks if c["name"] == name and c["app"]["id"] == app_id]
        latest = max(matching, key=lambda c: c["id"], default=None)
        if latest is None:
            blockers.append(f"{name}: missing")
        elif latest["status"] != "completed":
            blockers.append(f"{name}: pending")
        elif latest["conclusion"] != "success":
            blockers.append(f"{name}: {latest['conclusion']}")
    return blockers


def queue_members(entries, number):
    target = next((e for e in entries if e["pullRequest"]["number"] == number), None)
    if target is None:
        raise ValueError("Merge group no longer has a matching queue entry")
    return [
        e["pullRequest"]["number"]
        for e in entries
        if e["position"] <= target["position"]
    ]


def protection_ready(rules, required):
    if not any(rule["type"] == "merge_queue" for rule in rules):
        return False
    configured = {}
    for rule in rules:
        if rule["type"] == "required_status_checks":
            for check in rule["parameters"]["required_status_checks"]:
                configured[check["context"]] = check.get("integration_id")
    return all(configured.get(name) == app for name, app in required.items())
