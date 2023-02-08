args @ {
  self,
  inputs,
  lib,
  ...
}: let
  packagesModule = import ../packages args;
in {
  perSystem = psArgs @ {
    self',
    pkgs,
    ...
  }: let
    # load package derivations
    inherit (packagesModule.perSystem psArgs) packages;
    # import integration tests
    integrationTests = import ./../tests {inherit self' inputs pkgs;};
  in {
    checks =
      {
        statix =
          pkgs.runCommand "statix" {
            nativeBuildInputs = with pkgs; [statix];
          } ''
            cp --no-preserve=mode -r ${self} source
            cd source
            HOME=$TMPDIR statix check
            touch $out
          '';
      }
      # add integration tests for our custom nixosModules
      // integrationTests
      # merge in the package derivations to force a build of all packages during a `nix flake check`
      // packages;
  };
}
