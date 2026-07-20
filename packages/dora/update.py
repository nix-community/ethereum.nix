#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 nix-update prefetch-npm-deps
"""Update script for dora package.

nix-update handles version, source hash, and vendorHash but cannot update
npmDepsHash for the UI build. This script runs nix-update first, then
uses prefetch-npm-deps to compute the correct npmDepsHash.
"""

import re
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
PACKAGE_NIX = SCRIPT_DIR / "package.nix"
FLAKE_ROOT = SCRIPT_DIR.parent.parent


def run_nix_update() -> bool:
    """Run nix-update to handle version, hash, and vendorHash."""
    print("Running nix-update...")
    result = subprocess.run(
        ["nix-update", "--flake", "dora"],
        cwd=FLAKE_ROOT,
    )
    return result.returncode == 0


def get_src_path() -> str:
    """Get the store path of the dora source."""
    result = subprocess.run(
        ["nix", "build", ".#dora.src", "--no-link", "--print-out-paths"],
        capture_output=True,
        text=True,
        check=True,
        cwd=FLAKE_ROOT,
    )
    return result.stdout.strip()


def prefetch_npm_deps(lock_file: str) -> str:
    """Run prefetch-npm-deps on a package-lock.json and return the hash."""
    result = subprocess.run(
        ["prefetch-npm-deps", lock_file],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def update_npm_deps_hash() -> None:
    """Update npmDepsHash using prefetch-npm-deps."""
    print("Fetching source...")
    src_path = get_src_path()

    lock_file = f"{src_path}/ui-package/package-lock.json"
    print(f"Computing npmDepsHash from {lock_file}...")
    new_hash = prefetch_npm_deps(lock_file)
    print(f"npmDepsHash: {new_hash}")

    content = PACKAGE_NIX.read_text()
    content = re.sub(
        r'npmDepsHash = "sha256-[^"]*"',
        f'npmDepsHash = "{new_hash}"',
        content,
    )
    PACKAGE_NIX.write_text(content)


def main() -> None:
    if not run_nix_update():
        print("nix-update failed")
        sys.exit(1)

    update_npm_deps_hash()
    print("Done")


if __name__ == "__main__":
    main()
