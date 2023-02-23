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
    config,
    ...
  }: {
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
      // config.tests
      # merge in the package derivations to force a build of all packages during a `nix flake check`
      // self'.packages;
  };
}
