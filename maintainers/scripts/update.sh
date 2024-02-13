#!/usr/bin/env bash

set -ex

rootDir="$(git rev-parse --show-toplevel)"

nixpkgs=$(nix eval --raw -f "$rootDir" "inputs.nixpkgs.outPath")
flake=$(nix eval --raw -f "$rootDir")

nix-shell --show-trace "${nixpkgs}/maintainers/scripts/update.nix" \
  --arg include-overlays "[(import $rootDir).overlays.default]" \
  --arg keep-going 'true' \
  --arg predicate "(
    let
        prefix = \"$flake/pkgs/\";
        prefixLen = builtins.stringLength prefix;
    in
        (path: pkg: (builtins.substring 0 prefixLen pkg.meta.position) == prefix)
  )"
