{
  imports = [
    ./nethermind.nix
  ];

  perSystem = {lib, ...}: {
    options.tests = with lib;
      mkOption {
        type = types.attrsOf types.package;
        default = {};
        description = "An attribute set of derivations that represent tests";
      };
  };
}
