#!/usr/bin/env bash

set -e

rootDir="$(git rev-parse --show-toplevel)"
updateScript="maintainers/scripts/update/update.nix"

nix-shell "${rootDir}/${updateScript}" \
  --argstr flakePath "${rootDir}" \
  --arg keep-going 'true' \
  --arg commit "true" \
  --arg max-workers "4" \
  --arg no-confirm "true"
