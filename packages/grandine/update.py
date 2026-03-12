#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 nix-update nix-prefetch-scripts

import json
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
FLAKE_ROOT = SCRIPT_DIR.parent.parent
PACKAGE_NIX = SCRIPT_DIR / "package.nix"
HASHES_JSON = SCRIPT_DIR / "hashes.json"
OWNER = "grandinetech"
REPO = "grandine"


def run_nix_update() -> bool:
    """Run nix-update to handle version and source hash."""
    print("Running nix-update...")
    result = subprocess.run(
        [
            "nix-update",
            "--flake",
            "grandine",
            "--version-regex",
            "^([0-9]+\\.[0-9]+\\.[0-9]+)$",
        ],
        cwd=FLAKE_ROOT,
    )
    return result.returncode == 0


def prefetch_url(url: str) -> str:
    result = subprocess.run(
        ["nix-prefetch-url", "--type", "sha256", url],
        capture_output=True,
        text=True,
        check=True,
    )
    hash_base32 = result.stdout.strip()
    result = subprocess.run(
        ["nix-hash", "--to-sri", "--type", "sha256", hash_base32],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def main():
    if not run_nix_update():
        print("nix-update failed")
        sys.exit(1)

    version = subprocess.run(
        ["nix", "eval", "--raw", ".#grandine.version"],
        capture_output=True,
        text=True,
        check=True,
        cwd=FLAKE_ROOT,
    ).stdout

    # Update hashes.json
    hashes = {}
    for system, suffix in [
        ("x86_64-linux", "linux-x64"),
        ("aarch64-linux", "linux-arm64"),
    ]:
        url = f"https://github.com/{OWNER}/{REPO}/releases/download/{version}/grandine-{version}-{suffix}"
        print(f"Prefetching {url} for {system}...")
        try:
            new_hash = prefetch_url(url)
            print(f"  New hash: {new_hash}")
        except subprocess.CalledProcessError as e:
            print(f"  Error prefetching {url}: {e}")
            sys.exit(1)
        hashes[system] = {"url": url, "hash": new_hash}

    HASHES_JSON.write_text(json.dumps(hashes, indent=2) + "\n")
    print("Successfully updated Grandine")


if __name__ == "__main__":
    main()
