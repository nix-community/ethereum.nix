{
  pkgs,
  flake,
  system,
  ...
}:
let
  check = import ../lib/package-metadata.nix pkgs.lib;
  problems = pkgs.lib.concatLists (pkgs.lib.mapAttrsToList check flake.packages.${system});
in
if problems != [ ] then
  throw ("Incomplete package metadata:\n" + pkgs.lib.concatStringsSep "\n" problems)
else
  pkgs.runCommand "package-metadata" { } ''
    touch $out
  ''
