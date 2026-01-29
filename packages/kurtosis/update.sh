#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-scripts
# shellcheck shell=bash

set -euo pipefail

# Get the latest version from GitHub releases
LATEST_VERSION=$(curl -s https://api.github.com/repos/kurtosis-tech/kurtosis-cli-release-artifacts/releases/latest | jq -r .tag_name)

echo "Latest version: $LATEST_VERSION"

# Update version in default.nix
sed -i "s/version = \".*\";/version = \"$LATEST_VERSION\";/" "$(dirname "$0")/default.nix"

# Fetch hashes for all platforms
declare -A PLATFORMS=(
  ["x86_64-linux"]="linux_amd64"
  ["aarch64-linux"]="linux_arm64"
  ["x86_64-darwin"]="darwin_amd64"
  ["aarch64-darwin"]="darwin_arm64"
)

# Create temporary JSON
TMP_JSON=$(mktemp)

echo "{" >"$TMP_JSON"

first=true
for platform in "${!PLATFORMS[@]}"; do
  suffix="${PLATFORMS[$platform]}"
  url="https://github.com/kurtosis-tech/kurtosis-cli-release-artifacts/releases/download/${LATEST_VERSION}/kurtosis-cli_${LATEST_VERSION}_${suffix}.tar.gz"

  echo "Fetching hash for $platform ($suffix)..."
  hash=$(nix-prefetch-url "$url" 2>/dev/null)
  sri_hash=$(nix hash to-sri --type sha256 "$hash" 2>/dev/null | head -n1)

  if [ "$first" = true ]; then
    first=false
  else
    echo "," >>"$TMP_JSON"
  fi

  cat >>"$TMP_JSON" <<EOF
  "$platform": {
    "platformSuffix": "$suffix",
    "hash": "$sri_hash"
  }
EOF
done

echo "}" >>"$TMP_JSON"

# Pretty print and save
jq . "$TMP_JSON" >"$(dirname "$0")/hashes.json"
rm "$TMP_JSON"

echo "Updated to version $LATEST_VERSION"
