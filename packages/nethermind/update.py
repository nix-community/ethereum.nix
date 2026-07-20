#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 nix-update
"""Update script for nethermind package.

nix-update handles version and source hash but cannot update nuget-deps.json.
This script runs nix-update first, then uses the package's fetch-deps script
to regenerate nuget-deps.json.
"""

import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
FLAKE_ROOT = SCRIPT_DIR.parent.parent
NUGET_DEPS = SCRIPT_DIR / "nuget-deps.json"


def run_nix_update() -> bool:
    """Run nix-update to handle version and source hash."""
    print("Running nix-update...")
    result = subprocess.run(
        [
            "nix-update",
            "--flake",
            "nethermind",
            "--version-regex",
            "^([0-9]+\\.[0-9]+\\.[0-9]+)$",
            # https://github.com/Mic92/nix-update/issues/563
            "--src-only",
        ],
        cwd=FLAKE_ROOT,
    )
    return result.returncode == 0


def update_nuget_deps() -> None:
    """Regenerate nuget-deps.json using the package's fetch-deps script."""
    print("Building fetch-deps script...")
    result = subprocess.run(
        [
            "nix",
            "build",
            ".#nethermind.fetch-deps",
            "--no-link",
            "--print-out-paths",
        ],
        capture_output=True,
        text=True,
        check=True,
        cwd=FLAKE_ROOT,
    )
    fetch_deps_script = result.stdout.strip()

    print("Regenerating nuget-deps.json...")
    subprocess.run(
        [fetch_deps_script, str(NUGET_DEPS)],
        check=True,
        cwd=FLAKE_ROOT,
    )


def main() -> None:
    if not run_nix_update():
        print("nix-update failed")
        sys.exit(1)

    update_nuget_deps()
    print("Done")


if __name__ == "__main__":
    main()
