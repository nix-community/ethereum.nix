{
  inputs,
  packages,
  pkgs,
  self,
  system,
}:
{
  nix-lint =
    pkgs.runCommand "nix-linter" {
      nativeBuildInputs = with pkgs; [nix-linter];
    } ''
      # keep timestamps so that treefmt is able to detect mtime changes
      cp --no-preserve=mode --preserve=timestamps -r ${self} source
      cd source
      HOME=$TMPDIR nix-linter *.nix
      touch $out
    '';
}
# nix build support only pointing to a single derivation
# by including packages we can build all of them in one go
# see: https://zimbatm.com/notes/nixflakes
// packages
