#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix sd

set -e

pname="besu"
dirname="$(dirname "$0")"
rootDir="$(git -C "$dirname" rev-parse --show-toplevel)"

updateVersion() {
  local version=$1
  sd "version = \"[0-9.]*\";" "version = \"$version\";" "${dirname}/default.nix"
}

updateHash() {
  local version=$1
  local url="https://hyperledger.jfrog.io/hyperledger/${pname}-binaries/${pname}/${version}/${pname}-${version}.tar.gz"
  local sriHash=$(nix store prefetch-file --json "$url" | jq -r '.hash')
  sd 'hash = "[a-zA-Z0-9/+-=]*";' "hash = \"$sriHash\";" "${dirname}/default.nix"
}

currentVersion=$(nix derivation show "${rootDir}#${pname}" | jq -r '.[].env.version')
latestVersion=$(curl -s "https://hyperledger.jfrog.io/artifactory/api/search/latestVersion?g=org.hyperledger.besu.internal&a=besu")

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "${pname} is up to date: ${currentVersion}"
  exit 0
fi

echo "Updating ${pname} from ${currentVersion} to ${latestVersion}"

updateVersion "$latestVersion"
updateHash "$latestVersion"
