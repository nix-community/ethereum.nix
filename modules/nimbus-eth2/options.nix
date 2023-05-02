{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;
  nimbusOpts = with lib; {
    options = {
      enable = mkEnableOption (mdDoc "Nimbus Beacon Node service");

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["--num-threads=1" "--graffiti=1337_h4x0r"];
        description = mdDoc "Additional arguments passed to node.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.nimbus-eth2;
        defaultText = literalExpression "pkgs.nimbus-eth2";
        description = mdDoc "Package to use for Nimbus Beacon Node binary";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
      };

      # mixin backup options
      backup = let
        inherit (import ../backup/lib.nix lib) options;
      in
        options;

      # mixin restore options
      restore = let
        inherit (import ../restore/lib.nix lib) options;
      in
        options;
    };
  };
in {
  options.services.ethereum.nimbus-eth2 = with lib;
    mkOption {
      type = types.attrsOf (types.submodule nimbusOpts);
      default = {};
      description = mdDoc "Specification of one or more Nimbus Beacon Node instances.";
    };
}
