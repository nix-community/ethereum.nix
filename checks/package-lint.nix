{ pkgs, flake, ... }:
pkgs.runCommand "package-lint" { nativeBuildInputs = [ pkgs.ast-grep ]; } ''
  cp -r ${flake}/rules rules
  cp ${flake}/sgconfig.yml sgconfig.yml
  cp -r ${flake}/packages packages
  ast-grep scan --config sgconfig.yml packages
  ast-grep test --config sgconfig.yml --skip-snapshot-tests
  touch $out
''
