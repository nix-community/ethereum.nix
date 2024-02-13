#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix sd

set -e

pname="teku"
dirname="${PRJ_ROOT/pkgs/${pname}/:-$(dirname "$0")}"
rootDir="$(git -C "$dirname" rev-parse --show-toplevel)"

updateVersion() {
  local version=$1
  sd "version = \"[0-9.]*\";" "version = \"$version\";" "${dirname}/default.nix"
}

updateHash() {
  local version=$1
  local url="https://artifacts.consensys.net/public/${pname}/raw/names/${pname}.tar.gz/versions/${version}/${pname}-${version}.tar.gz"
  local sriHash=$(nix store prefetch-file --json "$url" | jq -r '.hash')
  sd 'hash = "[a-zA-Z0-9/+-=]*";' "hash = \"$sriHash\";" "${dirname}/default.nix"
}

currentVersion=$(nix derivation show "${rootDir}#${pname}" | jq -r '.[].env.version')
latestVersion=$(curl -s "https://api.github.com/repos/ConsenSys/teku/releases/latest" | jq -r '.tag_name')

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "${pname} is up to date: ${currentVersion}"
  exit 0
fi

echo "Updating ${pname} from ${currentVersion} to ${latestVersion}"

updateVersion "$latestVersion"
updateHash "$latestVersion"

