/*
* Derived from https://github.com/NixOS/nixpkgs/blob/45b92369d6fafcf9e462789e98fbc735f23b5f64/nixos/modules/services/blockchain/ethereum/geth.nix
*/
{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix {inherit lib pkgs;};
  inherit (modulesLib) mkArgs baseServiceConfig scripts;

  # capture config for all configured geths
  eachBootnode = config.services.ethereum.geth-bootnode;

  # submodule options
  bootnodeOpts = {
    options = with lib; rec {
      enable = mkEnableOption (mdDoc "Go Ethereum Boot Node");

      args = {
        addr = mkOption {
          # todo use regex matching
          type = types.str;
          default = ":30301";
          description = mdDoc "Listen address";
        };

        genkey = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = mdDoc "Generate a node key";
        };

        nat = mkOption {
          # todo use regex matching
          type = types.str;
          default = "none";
          description = mdDoc "Port mapping mechanism (any|none|upnp|pmp|pmp:<IP>|extip:<IP>)";
        };

        netrestrict = mkOption {
          # todo use regex matching
          type = types.nullOr types.str;
          default = null;
          description = mdDoc "Restrict network communication to the given IP networks (CIDR masks)";
        };

        nodekey = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = mdDoc "Private key filename";
        };

        nodekeyhex = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = mdDoc "Private key as hex (for testing)";
        };

        v5 = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = mdDoc "Run a V5 topic discovery bootnode";
        };

        verbosity = mkOption {
          type = types.ints.between 0 5;
          default = 3;
          description = mdDoc "log verbosity (0-5)";
        };

        vmodule = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = mdDoc "Log verbosity pattern";
        };

        writeaddress = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = mdDoc "Write out the node's public key and quit";
        };
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to the Go Ethereum Bootnode.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.geth;
        defaultText = literalExpression "pkgs.geth";
        description = mdDoc "Package to use as Go Ethereum Boot node.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  # Disable the service definition currently in nixpkgs
  disabledModules = ["services/blockchain/ethereum/geth.nix"];

  ###### interface

  options = {
    services.ethereum.geth-bootnode = with lib;
      mkOption {
        type = types.attrsOf (types.submodule bootnodeOpts);
        default = {};
        description = mdDoc "Specification of one or more geth bootnode instances.";
      };
  };

  ###### implementation

  config = with lib;
    mkIf (eachBootnode != {}) {
      # configure the firewall for each service
      networking.firewall = let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBootnode;
        perService =
          mapAttrsToList
          (
            _: cfg:
              with cfg.args; let
                # todo this can probably be improved with regex
                port = toInt (last (builtins.split ":" addr));
              in {
                allowedUDPPorts = [port];
              }
          )
          openFirewall;
      in
        zipAttrsWith (name: flatten) perService;

      # create a service for each instance
      systemd.services =
        mapAttrs'
        (
          gethName: let
            serviceName = "geth-bootnode-${gethName}";
          in
            cfg: let
              scriptArgs = let
                # of course flags for this process are `-foo` instead of `--foo`...
                pathReducer = path: let
                  arg = concatStringsSep "-" path;
                in "-${arg}";

                # generate flags
                args = mkArgs {
                  inherit pathReducer;
                  inherit (cfg) args;
                  opts = bootnodeOpts.options.args;
                };

                # filter out certain args which need to be treated differently
                specialArgs = ["-nodekey"];
                isNormalArg = name: (findFirst (arg: arg == name) null specialArgs) == null;

                filteredArgs = builtins.filter isNormalArg args;

                nodekey =
                  if cfg.args.nodekey != null
                  then "-nodekey %d/nodekey"
                  else "";
              in ''
                ${concatStringsSep " \\\n" filteredArgs} \
                ${lib.escapeShellArgs cfg.extraArgs}
              '';
            in
              nameValuePair serviceName (mkIf cfg.enable {
                after = ["network.target"];
                wantedBy = ["multi-user.target"];
                description = "Go Ethereum Bootnode (${gethName})";

                # create service config by merging with the base config
                serviceConfig = mkMerge [
                  baseServiceConfig
                  {
                    User = serviceName;
                    StateDirectory = serviceName;
                    ExecStart = "${cfg.package}/bin/bootnode ${scriptArgs}";
                  }
                  (mkIf (cfg.args.nodekey != null) {
                    LoadCredential = ["nodekey:${cfg.args.nodekey}"];
                  })
                ];
              })
        )
        eachBootnode;
    };
}
