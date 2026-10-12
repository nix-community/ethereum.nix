#!/usr/bin/env bash
set -euo pipefail

# Script to perform updates for packages or flake inputs
# Usage: update.sh <type> <name>
#   type: "package" or "flake-input"
#   name: package name or input name
#
# Note that we don't build the package within Github Actions since buildbot does it after the PR is opened.

type="$1"
name="$2"

export NIX_PATH=nixpkgs=flake:nixpkgs

# Outputs are written to GITHUB_OUTPUT if available
output_var="${GITHUB_OUTPUT:-/dev/stdout}"

if [ "$type" = "package" ]; then
  script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
  exec python3 "$script_dir/../ci/update.py" "$name"

elif [ "$type" = "flake-input" ]; then
  echo "Updating input $name..."

  if nix flake update "$name"; then
    # Check if there were actual changes
    if [[ -z $(git status --porcelain) ]]; then
      echo "No changes detected"
      echo "updated=false" >>"$output_var"
      exit 0
    fi

    # Get new revision
    new_rev=$(nix flake metadata --json --no-write-lock-file | jq -r ".locks.nodes.\"$name\".locked.rev // \"unknown\"" | head -c 8)
    echo "New revision: $new_rev"

    echo "updated=true" >>"$output_var"
    echo "new_version=$new_rev" >>"$output_var"
  else
    echo "::error::Failed to update $name"
    exit 1
  fi
else
  echo "Error: Unknown type '$type'. Must be 'package' or 'flake-input'."
  exit 1
fi
