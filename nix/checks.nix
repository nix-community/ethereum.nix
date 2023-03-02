{
  self,
  lib,
  ...
}: {
  perSystem = {
    self',
    inputs',
    pkgs,
    config,
    ...
  }: {
    checks = let
      inherit (inputs'.nixpkgs-unstable.legacyPackages) statix;
    in
      {
        statix =
          pkgs.runCommand "statix" {
            nativeBuildInputs = [statix];
          } ''
            cp --no-preserve=mode -r ${self} source
            cd source
            HOME=$TMPDIR statix check
            touch $out
          '';
      }
      # mix in tests
      // config.testing.checks
      # merge in the package derivations to force a build of all packages during a `nix flake check`
      // (with lib; mapAttrs' (n: nameValuePair "package-${n}") self'.packages);
  };
}
