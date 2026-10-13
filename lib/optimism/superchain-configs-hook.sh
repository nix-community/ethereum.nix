# shellcheck shell=bash

superchainConfigsPreBuild() {
  echo "Executing superchainConfigsPreBuild"
  # unpackPhase only makes sourceRoot writable; the script copies from and
  # writes into these sibling trees, so make them writable too.
  chmod -R u+w ../op-core ../superchain-registry
  patchShebangs ../op-core/superchain/sync-superchain.sh
  bash ../op-core/superchain/sync-superchain.sh
}

preBuildHooks+=(superchainConfigsPreBuild)
