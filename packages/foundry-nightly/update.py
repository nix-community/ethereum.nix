#!/usr/bin/env python3
"""Update foundry-nightly to the latest nightly release."""

import json
import re
import subprocess
import sys
from pathlib import Path


def get_latest_nightly():
    """Fetch the latest nightly release info from GitHub."""
    result = subprocess.run(
        [
            "gh",
            "api",
            "repos/foundry-rs/foundry/releases",
            "--jq",
            '.[] | select(.tag_name | startswith("nightly-") and (. != "nightly")) | {tag_name, published_at}',
        ],
        capture_output=True,
        text=True,
        check=True,
    )

    # Get first (latest) nightly
    for line in result.stdout.strip().split("\n"):
        if line:
            release = json.loads(line)
            return release
    return None


def get_hash_from_build_error(package_nix_path):
    """Run nix build and extract hash from error message."""
    result = subprocess.run(
        ["nix", "build", ".#foundry-nightly", "--no-link"],
        capture_output=True,
        text=True,
        cwd=package_nix_path.parent.parent.parent,
    )

    # Look for hash in stderr
    output = result.stderr
    match = re.search(r"got:\s+(sha256-[A-Za-z0-9+/]+=*)", output)
    if match:
        return match.group(1)
    return None


def main():
    package_dir = Path(__file__).parent
    package_nix = package_dir / "package.nix"

    # Get current version
    content = package_nix.read_text()
    current_tag_match = re.search(r'nightlyTag = "([^"]+)"', content)
    if not current_tag_match:
        print("Could not find nightlyTag in package.nix")
        sys.exit(1)

    current_tag = current_tag_match.group(1)
    print(f"Current: {current_tag}")

    # Get latest nightly
    latest = get_latest_nightly()
    if not latest:
        print("Could not fetch latest nightly")
        sys.exit(1)

    new_tag = latest["tag_name"]
    # Extract date from published_at (format: 2026-02-16T06:26:46Z)
    new_date = latest["published_at"][:10]

    print(f"Latest:  {new_tag} ({new_date})")

    if current_tag == new_tag:
        print("Already up to date")
        return

    # Update package.nix with new tag and date
    new_content = re.sub(
        r'nightlyTag = "[^"]+"',
        f'nightlyTag = "{new_tag}"',
        content,
    )
    new_content = re.sub(
        r'nightlyDate = "[^"]+"',
        f'nightlyDate = "{new_date}"',
        new_content,
    )

    # Clear hashes first
    new_content = re.sub(
        r'(hash = )"sha256-[^"]+"',
        r'\1""',
        new_content,
    )
    new_content = re.sub(
        r'(cargoHash = )"sha256-[^"]+"',
        r'\1""',
        new_content,
    )
    package_nix.write_text(new_content)

    # Get source hash
    print("Computing source hash...")
    src_hash = get_hash_from_build_error(package_nix)
    if not src_hash:
        print("ERROR: Could not determine source hash")
        sys.exit(1)
    print(f"Source hash: {src_hash}")

    # Update source hash
    new_content = re.sub(
        r'(hash = )""',
        f'\\1"{src_hash}"',
        new_content,
    )
    package_nix.write_text(new_content)

    # Get cargo hash
    print("Computing cargo hash...")
    cargo_hash = get_hash_from_build_error(package_nix)
    if not cargo_hash:
        print("ERROR: Could not determine cargo hash")
        sys.exit(1)
    print(f"Cargo hash: {cargo_hash}")

    # Update cargo hash
    new_content = re.sub(
        r'(cargoHash = )""',
        f'\\1"{cargo_hash}"',
        new_content,
    )
    package_nix.write_text(new_content)

    print(f"Updated to {new_tag}")


if __name__ == "__main__":
    main()
