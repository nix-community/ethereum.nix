#!/usr/bin/env bash

set -e

rootDir="$(git rev-parse --show-toplevel)"
updateScript="maintainers/scripts/update/update.nix"

nix-shell "${rootDir}/${updateScript}" \
  --argstr flakePath "${rootDir}" \
  --argstr keep-going 'true' \
  --argstr max-workers "4" \
  --argstr no-confirm "true" \
  --argstr commit 'true'
