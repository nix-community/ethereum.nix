{
  self',
  inputs,
  pkgs,
}: let
  makeTest = import (inputs.nixpkgs + "/nixos/tests/make-test-python.nix");
in {
  nethermind-integration-tests = import ./nethermind.nix {inherit self' makeTest pkgs;};
}
