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
        # TODO: Switch to statix instead
        # nix-lint =
        #   pkgs.runCommand "nix-linter" {
        #     nativeBuildInputs = with pkgs; [nix-linter];
        #   } ''
        #     cp --no-preserve=mode -r ${self} source
        #     rm -rf source/.direnv # delete .direnv cache so nix-linter don't recurse it
        #     cd source
        #     HOME=$TMPDIR nix-linter --recursive
        #     touch $out
        #   '';
      }
      # merge in the package derivations to force a build of all packages during a `nix flake check`
      // packages;
  };
}
