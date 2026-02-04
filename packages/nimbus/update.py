#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 nix-prefetch-git jq
"""Update script for nimbus-eth2 package.

This script handles the complex update process for nimbus which requires:
1. Updating the main nimbus-eth2 source
2. Extracting pinned Nim compiler dependency commits from submodules
3. Updating nimble.nix, csources.nix, and checksums.nix with correct commits/hashes
"""

import json
import re
import subprocess
from pathlib import Path
from urllib.request import urlopen

SCRIPT_DIR = Path(__file__).parent
OWNER = "status-im"
REPO = "nimbus-eth2"


def fetch_json(url: str) -> dict:
    """Fetch JSON from URL."""
    with urlopen(url) as response:
        return json.loads(response.read().decode())


def fetch_text(url: str) -> str:
    """Fetch text from URL."""
    with urlopen(url) as response:
        return response.read().decode()


def get_latest_version() -> str:
    """Get latest stable release version."""
    releases = fetch_json(f"https://api.github.com/repos/{OWNER}/{REPO}/releases")
    for release in releases:
        if not release["prerelease"] and not release["draft"]:
            return release["tag_name"].lstrip("v")
    raise ValueError("No stable release found")


def get_current_version() -> str:
    """Get current version from package.nix."""
    content = (SCRIPT_DIR / "package.nix").read_text()
    match = re.search(r'version = "([^"]+)"', content)
    if match:
        return match.group(1)
    raise ValueError("Could not find version in package.nix")


def get_submodule_commit(owner: str, repo: str, ref: str, path: str) -> str:
    """Get the commit SHA of a submodule at a given path."""
    url = f"https://api.github.com/repos/{owner}/{repo}/contents/{path}?ref={ref}"
    data = fetch_json(url)
    if data.get("type") == "submodule":
        return data["sha"]
    raise ValueError(f"Path {path} is not a submodule")


def get_file_content(owner: str, repo: str, ref: str, path: str) -> str:
    """Get raw file content from GitHub."""
    url = f"https://raw.githubusercontent.com/{owner}/{repo}/{ref}/{path}"
    return fetch_text(url)


def extract_nim_commits(nim_ref: str) -> dict:
    """Extract NimbleStableCommit and ChecksumsStableCommit from koch.nim."""
    koch_content = get_file_content("nim-lang", "Nim", nim_ref, "koch.nim")

    nimble_match = re.search(r'NimbleStableCommit = "([a-f0-9]+)"', koch_content)
    checksums_match = re.search(r'ChecksumsStableCommit = "([a-f0-9]+)"', koch_content)

    if not nimble_match or not checksums_match:
        raise ValueError("Could not extract commits from koch.nim")

    return {
        "nimble": nimble_match.group(1),
        "checksums": checksums_match.group(1),
    }


def extract_csources_commit(nim_ref: str) -> str:
    """Extract nim_csourcesHash from build_config.txt."""
    config_content = get_file_content(
        "nim-lang", "Nim", nim_ref, "config/build_config.txt"
    )

    match = re.search(r"nim_csourcesHash=([a-f0-9]+)", config_content)
    if not match:
        raise ValueError("Could not extract csources hash from build_config.txt")

    return match.group(1)


def prefetch_github(
    owner: str, repo: str, rev: str, fetch_submodules: bool = False
) -> str:
    """Prefetch a GitHub repo and return the hash."""
    cmd = [
        "nix-prefetch-git",
        "--url",
        f"https://github.com/{owner}/{repo}",
        "--rev",
        rev,
        "--quiet",
    ]
    if fetch_submodules:
        cmd.append("--fetch-submodules")

    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    return data["hash"]


def update_nix_file(path: Path, updates: dict) -> None:
    """Update a .nix file with new values."""
    content = path.read_text()
    for key, value in updates.items():
        if key == "rev":
            content = re.sub(r'rev = "[^"]+";', f'rev = "{value}";', content)
        elif key == "hash":
            content = re.sub(r'hash = "[^"]+";', f'hash = "{value}";', content)
        elif key == "version":
            content = re.sub(r'version = "[^"]+";', f'version = "{value}";', content)
    path.write_text(content)


def main() -> None:
    current_version = get_current_version()
    latest_version = get_latest_version()

    print(f"Current version: {current_version}")
    print(f"Latest version: {latest_version}")

    if current_version == latest_version:
        print("Already up to date")
        return

    tag = f"v{latest_version}"

    # Step 1: Get the nimbus-build-system submodule commit
    print("Fetching submodule structure...")
    nbs_commit = get_submodule_commit(OWNER, REPO, tag, "vendor/nimbus-build-system")
    print(f"  nimbus-build-system: {nbs_commit[:8]}")

    # Step 2: Get the Nim submodule commit from nimbus-build-system
    nim_commit = get_submodule_commit(
        "status-im", "nimbus-build-system", nbs_commit, "vendor/Nim"
    )
    print(f"  Nim: {nim_commit[:8]}")

    # Step 3: Extract pinned commits from Nim repo
    print("Extracting Nim dependency commits...")
    nim_commits = extract_nim_commits(nim_commit)
    csources_commit = extract_csources_commit(nim_commit)
    print(f"  nimble: {nim_commits['nimble'][:8]}")
    print(f"  checksums: {nim_commits['checksums'][:8]}")
    print(f"  csources: {csources_commit[:8]}")

    # Step 4: Prefetch all sources and get hashes
    print("Prefetching sources (this may take a while)...")

    print("  Fetching nimbus-eth2...")
    nimbus_hash = prefetch_github(OWNER, REPO, tag, fetch_submodules=True)
    print(f"    hash: {nimbus_hash[:20]}...")

    print("  Fetching nimble...")
    nimble_hash = prefetch_github(
        "nim-lang", "nimble", nim_commits["nimble"], fetch_submodules=True
    )
    print(f"    hash: {nimble_hash[:20]}...")

    print("  Fetching checksums...")
    checksums_hash = prefetch_github("nim-lang", "checksums", nim_commits["checksums"])
    print(f"    hash: {checksums_hash[:20]}...")

    print("  Fetching csources_v2...")
    csources_hash = prefetch_github("nim-lang", "csources_v2", csources_commit)
    print(f"    hash: {csources_hash[:20]}...")

    # Step 5: Update all .nix files
    print("Updating .nix files...")

    update_nix_file(
        SCRIPT_DIR / "package.nix",
        {
            "version": latest_version,
            "hash": nimbus_hash,
        },
    )
    print("  Updated package.nix")

    update_nix_file(
        SCRIPT_DIR / "nimble.nix",
        {
            "rev": nim_commits["nimble"],
            "hash": nimble_hash,
        },
    )
    print("  Updated nimble.nix")

    update_nix_file(
        SCRIPT_DIR / "checksums.nix",
        {
            "rev": nim_commits["checksums"],
            "hash": checksums_hash,
        },
    )
    print("  Updated checksums.nix")

    update_nix_file(
        SCRIPT_DIR / "csources.nix",
        {
            "rev": csources_commit,
            "hash": csources_hash,
        },
    )
    print("  Updated csources.nix")

    print(
        f"\nSuccessfully updated nimbus-eth2 from {current_version} to {latest_version}"
    )


if __name__ == "__main__":
    main()
