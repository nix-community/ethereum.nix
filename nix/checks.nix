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
  in {
    checks =
      {
        nix-lint =
          pkgs.runCommand "nix-lint" {
            nativeBuildInputs = with pkgs; [statix];
          } ''
            cp --no-preserve=mode -r ${self} source
            cd source
            HOME=$TMPDIR statix check
            touch $out
          '';
      }
      # merge in the package derivations to force a build of all packages during a `nix flake check`
      // packages;
  };
}
