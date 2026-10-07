{ pkgs, flake, ... }:
pkgs.runCommand "automation-tests"
  {
    nativeBuildInputs = [
      pkgs.python3
      pkgs.git
    ];
  }
  ''
    cp -r ${flake}/.github github
    cp -r ${flake}/packages packages
    chmod -R u+w github packages
    export HOME=$TMPDIR
    export PYTHONDONTWRITEBYTECODE=1
    python3 -m unittest discover -s github/ci/tests -v
    touch $out
  ''
