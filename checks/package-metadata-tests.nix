{ pkgs, ... }:
let
  check = import ../lib/package-metadata.nix pkgs.lib;
  package = {
    passthru.category = "Utilities";
    meta = {
      description = "Fixture";
      homepage = "https://example.org";
      changelog = "https://example.org/releases";
      license = pkgs.lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ pkgs.lib.sourceTypes.fromSource ];
      mainProgram = "fixture";
      maintainers = [ ];
    };
  };
  library = package // {
    passthru.category = "Libraries";
    meta = builtins.removeAttrs package.meta [ "mainProgram" ];
  };
  broken = package // {
    meta = package.meta // {
      maintainers = [ (throw "unresolved maintainer") ];
    };
  };
in
assert check "valid" package == [ ];
assert check "library" library == [ ];
assert check "missing" (package // { meta = { }; }) != [ ];
assert !(builtins.tryEval (builtins.deepSeq (check "broken" broken) true)).success;
pkgs.runCommand "package-metadata-tests" { } ''
  touch $out
''
