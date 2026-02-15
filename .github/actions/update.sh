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
  echo "Updating package $name..."

  # Check if package has a custom update script
  update_script=""
  if [ -f "packages/$name/update.sh" ]; then
    update_script="packages/$name/update.sh"
  elif [ -f "packages/$name/update.py" ]; then
    update_script="packages/$name/update.py"
  fi

  if [ -n "$update_script" ]; then
    echo "Running update script: $update_script"
    if output=$("$update_script" 2>&1); then
      echo "$output"
    else
      echo "::error::Update script failed for package $name"
      echo "$output"
      exit 1
    fi
  else
    # Try nix-update as fallback
    echo "No update script found, trying nix-update..."

    # Build nix-update arguments
    nix_update_args=(--flake)

    # Check for custom nix-update-args file
    if [ -f "packages/$name/nix-update-args" ]; then
      echo "Loading custom nix-update-args..."
      while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z $line || $line =~ ^# ]] && continue
        nix_update_args+=("$line")
      done <"packages/$name/nix-update-args"
    else
      # Default to stable version if no custom args
      nix_update_args+=(--version=stable)
    fi

    echo "Running: nix-update ${nix_update_args[*]} $name"
    if output=$(nix-update "${nix_update_args[@]}" "$name" 2>&1); then
      echo "$output"
    else
      echo "::error::nix-update failed for package $name"
      echo "$output"
      exit 1
    fi
  fi

  # Check if there were actual changes
  if git diff --quiet; then
    echo "No changes detected"
    echo "updated=false" >>"$output_var"
    exit 0
  fi

  # Get the new version
  new_version=$(nix eval .#packages.x86_64-linux."$name".version --raw 2>/dev/null || echo "unknown")
  echo "New version: $new_version"

  # Run formatter to update README with mdsh
  echo "Running formatter to update documentation..."
  nix fmt

  echo "updated=true" >>"$output_var"
  echo "new_version=$new_version" >>"$output_var"

elif [ "$type" = "flake-input" ]; then
  echo "Updating input $name..."

  if nix flake update "$name"; then
    # Check if there were actual changes
    if git diff --quiet; then
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
