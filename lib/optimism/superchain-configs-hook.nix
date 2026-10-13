# Regenerates op-core/superchain/superchain-configs.zip before buildPhase.
#
# op-core/superchain embeds superchain-configs.zip via //go:embed. The zip is
# gitignored and regenerated from the superchain-registry submodule; init()
# panics unless the bundle matches the committed .sha256. Packages built from
# the optimism monorepo that import op-core/superchain need this hook and a
# `fetchSubmodules = true` source (the script asserts the .sha256 match).
{
  jq,
  makeSetupHook,
  yq-go,
  zip,
}:
makeSetupHook {
  name = "superchain-configs-hook";
  propagatedBuildInputs = [
    jq
    yq-go
    zip
  ];
} ./superchain-configs-hook.sh
