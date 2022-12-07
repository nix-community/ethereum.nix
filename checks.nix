{
  selfPkgs,
  pkgs,
  self,
}:
{
  nix-lint =
    pkgs.runCommand "nix-linter" {
      nativeBuildInputs = with pkgs; [nix-linter];
    } ''
      cp --no-preserve=mode -r ${self} source
      rm -rf source/.direnv # delete .direnv cache so nix-linter don't recurse it
      cd source
      HOME=$TMPDIR nix-linter --recursive
      touch $out
    '';
}
# nix build support only pointing to a single derivation
# by including packages we can build all of them in one go
# see: https://zimbatm.com/notes/nixflakes
// selfPkgs
