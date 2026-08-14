#!/usr/bin/env python3
"""Discover packages and flake inputs for update checking.

This script mimics what happens in the GitHub Actions workflow.
It discovers all packages with version attributes and all flake inputs,
outputting a matrix JSON suitable for GitHub Actions.
"""

import json
import os
import subprocess
from dataclasses import dataclass
from pathlib import Path

try:
    import yaml

    HAS_YAML = True
except ImportError:
    HAS_YAML = False


@dataclass
class MatrixItem:
    """Represents an item in the update matrix."""

    type: str
    name: str
    current_version: str

    def to_dict(self) -> dict[str, str]:
        """Convert to dictionary for JSON serialization."""
        return {
            "type": self.type,
            "name": self.name,
            "current_version": self.current_version,
        }


def load_update_config() -> dict:
    """Load update configuration from .github/config/update-config.yml."""
    config_path = Path(".github/config/update-config.yml")
    if not config_path.exists():
        return {}
    if not HAS_YAML:
        print("Warning: pyyaml not installed, skipping update config")
        return {}
    try:
        return yaml.safe_load(config_path.read_text()) or {}
    except yaml.YAMLError as e:
        print(f"Warning: Failed to parse update config: {e}")
        return {}


def run_nix(args: list[str]) -> subprocess.CompletedProcess[str]:
    """Run a nix command and return the result."""
    return subprocess.run(
        ["nix", *args],
        capture_output=True,
        text=True,
        check=False,
    )


def discover_packages(packages_filter: str | None, system: str) -> list[MatrixItem]:
    """Discover packages with version attributes in a single nix eval."""
    items: list[MatrixItem] = []

    print("Discovering packages...")

    # Build a nix expression that evaluates all versions at once
    # Returns { name: { version, skipAutoUpdate } } for each package
    # Pass data via env var + builtins.fromJSON to avoid string interpolation
    config = json.dumps(
        {
            "system": system,
            "filter": packages_filter.split() if packages_filter else None,
        }
    )
    expr = """
    let
      config = builtins.fromJSON (builtins.getEnv "DISCOVERY_CONFIG");
      flake = builtins.getFlake (toString ./.);
      pkgs = flake.packages.${config.system};
      getInfo = pkg:
        if pkg ? version then {
          version = pkg.version;
          skipAutoUpdate = pkg.passthru.skipAutoUpdate or false;
        } else null;
      getVersionFiltered = name:
        if pkgs ? ${name} && pkgs.${name} ? version
        then { inherit name; value = getInfo pkgs.${name}; }
        else null;
    in
      if config.filter == null then
        builtins.mapAttrs (_name: pkg: getInfo pkg) pkgs
      else
        builtins.listToAttrs
          (builtins.filter (x: x != null) (map getVersionFiltered config.filter))
    """
    env = {**os.environ, "DISCOVERY_CONFIG": config}
    result = subprocess.run(
        ["nix", "eval", "--json", "--impure", "--expr", expr],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )

    if result.returncode != 0:
        print(f"Failed to evaluate packages: {result.stderr}")
        return items

    packages_info = json.loads(result.stdout)

    for name in sorted(packages_info.keys()):
        info = packages_info[name]
        if info is None:
            if not packages_filter:
                print(f"Skipping {name} (no version attribute)")
            continue

        if info.get("skipAutoUpdate"):
            print(f"Skipping {name} (skipAutoUpdate = true)")
            continue

        items.append(
            MatrixItem(type="package", name=name, current_version=info["version"])
        )

    if packages_filter:
        # Warn about missing packages
        found = set(packages_info.keys())
        for pkg in packages_filter.split():
            if pkg not in found:
                print(f"Warning: Package {pkg} not found or has no version")

    return items


def discover_flake_inputs(
    inputs_filter: str | None, skip_inputs: list[str]
) -> list[MatrixItem]:
    """Discover flake inputs from flake.lock."""
    items: list[MatrixItem] = []

    print("Discovering flake inputs...")

    lock_path = Path("flake.lock")
    if not lock_path.exists():
        print("No flake.lock found, skipping input updates")
        return items

    # Read flake.lock directly - no need for nix command
    lock_data = json.loads(lock_path.read_text())
    nodes = lock_data.get("nodes", {})

    if inputs_filter:
        input_names = inputs_filter.split()
    else:
        input_names = sorted(k for k in nodes if k != "root")

    for input_name in input_names:
        if input_name not in nodes:
            continue

        if input_name in skip_inputs:
            print(f"Skipping {input_name} (in skip list)")
            continue

        locked = nodes[input_name].get("locked", {})
        rev = locked.get("rev", "unknown")[:8]
        items.append(
            MatrixItem(
                type="flake-input",
                name=input_name,
                current_version=rev,
            )
        )

    return items


def main() -> None:
    """Discover packages and flake inputs, output matrix for GitHub Actions."""
    # Get configuration from environment
    update_type = os.environ.get("UPDATE_TYPE", "").strip().lower()
    packages = os.environ.get("PACKAGES", "")
    inputs = os.environ.get("INPUTS", "")
    system = os.environ.get("SYSTEM", "x86_64-linux")
    github_output = os.environ.get("GITHUB_OUTPUT")

    # Load update config for skip lists
    update_config = load_update_config()
    skip_inputs = update_config.get("skip", {}).get("inputs", [])

    # Determine what to update based on UPDATE_TYPE
    update_packages = update_type in ("", "packages")
    update_inputs = update_type in ("", "inputs")

    print("=== Discovery Configuration ===")
    print(f"UPDATE_TYPE: {update_type or '<all>'}")
    print(f"PACKAGES: {packages or '<all>'}")
    print(f"INPUTS: {inputs or '<all>'}")
    if skip_inputs:
        print(f"Skip inputs: {', '.join(skip_inputs)}")
    print()

    # Discover items
    matrix_items: list[MatrixItem] = []
    if update_packages:
        matrix_items.extend(discover_packages(packages or None, system))
    if update_inputs:
        matrix_items.extend(discover_flake_inputs(inputs or None, skip_inputs))

    print()
    print("=== Discovery Results ===")

    # Create matrix JSON
    matrix: dict[str, list[dict[str, str]]]
    if not matrix_items:
        matrix = {"include": []}
        has_updates = False
        print("No items to update")
    else:
        matrix = {"include": [item.to_dict() for item in matrix_items]}
        has_updates = True
        print(f"Found {len(matrix_items)} item(s) to update")

    matrix_json = json.dumps(matrix, separators=(",", ":"))

    # Output for GitHub Actions
    if github_output:
        with Path(github_output).open("a") as f:
            f.write(f"matrix={matrix_json}\n")
            f.write(f"has-updates={str(has_updates).lower()}\n")
    else:
        # Local testing output
        print()
        print("=== GitHub Actions Output Format ===")
        print(f"matrix={matrix_json}")
        print(f"has-updates={str(has_updates).lower()}")

        print()
        print("=== Pretty-printed Matrix ===")
        print(json.dumps(matrix, indent=2))

        print()
        print("=== Summary ===")
        if has_updates:
            print("Items by type:")
            type_counts: dict[str, int] = {}
            for item in matrix_items:
                type_counts[item.type] = type_counts.get(item.type, 0) + 1
            for item_type, count in sorted(type_counts.items()):
                print(f"  {count} {item_type}")


if __name__ == "__main__":
    main()
