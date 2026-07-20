{
  lib,
  pkgs,
  ...
}:
let
  args = import ./args.nix lib;

  heliosOpts = with lib; {
    options = {
      enable = mkEnableOption "Helios light client.";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Helios.";
        default = [ ];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.helios;
        defaultText = literalExpression "pkgs.helios";
        description = "Package to use for the Helios binary.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open the RPC port in the firewall.";
      };

      startWhenNeeded = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to use socket activation to start Helios when a connection is made to the RPC port. Requires rpc.enable to be true.";
      };
    };
  };
in
{
  options.services.ethereum.helios =
    with lib;
    mkOption {
      type = types.attrsOf (types.submodule heliosOpts);
      default = { };
      description = "Specification of one or more Helios light client instances.";
    };
}
