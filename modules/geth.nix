/*
* Derived from https://github.com/NixOS/nixpkgs/blob/45b92369d6fafcf9e462789e98fbc735f23b5f64/nixos/modules/services/blockchain/ethereum/geth.nix
*/
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) optionals findFirst;
  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib) mdDoc flatten nameValuePair filterAttrs mapAttrs mapAttrs' mapAttrsToList;
  inherit (lib) optionalString literalExpression mkEnableOption mkIf mkOption types concatStringsSep;

  eachGeth = config.services.geth;

  gethOpts = {
    options = {
      enable = mkEnableOption (mdDoc "Go Ethereum Node");

      args = {
        datadir = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = mdDoc "Data directory to use for storing Geth state";
        };

        port = mkOption {
          type = types.port;
          default = 30303;
          description = mdDoc "Port number Go Ethereum will be listening on, both TCP and UDP.";
        };

        http = {
          enable = mkEnableOption (mdDoc "Go Ethereum HTTP API");

          addr = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "HTTP-RPC server listening interface";
          };

          port = mkOption {
            type = types.port;
            default = 8545;
            description = mdDoc "Port number of Go Ethereum HTTP API.";
          };

          api = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = mdDoc "API's offered over the HTTP-RPC interface";
            example = ["net" "eth"];
          };

          corsdomain = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = mdDoc "List of domains from which to accept cross origin requests";
            example = ["*"];
          };

          rpcprefix = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = mdDoc "HTTP path path prefix on which JSON-RPC is served. Use '/' to serve on all paths.";
            example = "/";
          };

          vhosts = mkOption {
            type = types.listOf types.str;
            default = ["localhost"];
            description = mdDoc ''
              Comma separated list of virtual hostnames from which to accept requests (server enforced).
              Accepts '*' wildcard.
            '';
            example = ["localhost" "geth.example.org"];
          };
        };

        ws = {
          enable = mkEnableOption (mdDoc "Go Ethereum WebSocket API");
          addr = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "Listen address of Go Ethereum WebSocket API.";
          };

          port = mkOption {
            type = types.port;
            default = 8546;
            description = mdDoc "Port number of Go Ethereum WebSocket API.";
          };

          api = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = mdDoc "APIs to enable over WebSocket";
            example = ["net" "eth"];
          };
        };

        authrpc = {
          addr = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "Listen address of Go Ethereum Auth RPC API.";
          };

          port = mkOption {
            type = types.port;
            default = 8551;
            description = mdDoc "Port number of Go Ethereum Auth RPC API.";
          };

          vhosts = mkOption {
            type = types.listOf types.str;
            default = ["localhost"];
            description = mdDoc "List of virtual hostnames from which to accept requests.";
            example = ["localhost" "geth.example.org"];
          };

          jwtsecret = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = mdDoc "Path to a JWT secret for authenticated RPC endpoint.";
            example = "/var/run/geth/jwtsecret";
          };
        };

        metrics = {
          enable = mkEnableOption (mdDoc "Go Ethereum prometheus metrics");
          addr = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "Listen address of Go Ethereum metrics service.";
          };

          port = mkOption {
            type = types.port;
            default = 6060;
            description = mdDoc "Port number of Go Ethereum metrics service.";
          };
        };

        network = mkOption {
          type = types.nullOr (types.enum ["goerli" "kiln" "rinkeby" "ropsten" "sepolia"]);
          default = null;
          description = mdDoc "The network to connect to. Mainnet (null) is the default ethereum network.";
        };

        syncmode = mkOption {
          type = types.enum ["snap" "fast" "full" "light"];
          default = "snap";
          description = mdDoc "Blockchain sync mode.";
        };

        gcmode = mkOption {
          type = types.enum ["full" "archive"];
          default = "full";
          description = mdDoc "Blockchain garbage collection mode.";
        };

        maxpeers = mkOption {
          type = types.int;
          default = 50;
          description = mdDoc "Maximum peers to connect to.";
        };
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Go Ethereum.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.geth;
        defaultText = literalExpression "pkgs.geth";
        description = mdDoc "Package to use as Go Ethereum node.";
      };

      service = {
        supplementaryGroups = mkOption {
          default = [];
          type = types.listOf types.str;
          description = mdDoc "Additional groups for the systemd service e.g. sops-nix group for secret access";
        };
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
    services.geth = mkOption {
      type = types.attrsOf (types.submodule gethOpts);
      default = {};
      description = mdDoc "Specification of one or more geth instances.";
    };
  };

  ###### implementation

  config = mkIf (eachGeth != {}) {
    # collect packages and add them to the system
    environment.systemPackages = flatten (mapAttrsToList
      (_: cfg: [
        cfg.package
      ])
      eachGeth);

    # add a group for each instance
    users.groups =
      mapAttrs'
      (gethName: _: nameValuePair "geth-${gethName}" {})
      eachGeth;

    # add a system user for each instance
    users.users =
      mapAttrs'
      (gethName: _:
        nameValuePair "geth-${gethName}" {
          isSystemUser = true;
          group = "geth-${gethName}";
          description = "System user for geth ${gethName} instance";
        })
      eachGeth;

    # ensure data directories are created and have the correct permissions for any instances that specify one
    systemd.tmpfiles.rules =
      lib.lists.flatten
      (mapAttrsToList
        (
          gethName: cfg:
            lib.lists.optionals (cfg.args.datadir != null) [
              "d ${cfg.args.datadir} 0700 geth-${gethName} geth-${gethName} - -"
            ]
        )
        eachGeth);

    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachGeth;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [port];
              allowedTCPPorts =
                [port authrpc.port]
                ++ (optionals http.enable [http.port])
                ++ (optionals ws.enable [ws.port])
                ++ (optionals metrics.enable [metrics.port]);
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
          statedir = "geth-${gethName}";
          datadir = "/var/lib/${statedir}";

          modulesLib = import ./lib.nix {inherit lib pkgs;};
          inherit (modulesLib.flags) mkFlags;
        in
          cfg:
            nameValuePair "geth-${gethName}" (mkIf cfg.enable {
              description = "Go Ethereum node (${gethName})";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];

              unitConfig = {
                RequiresMountsFor = optionals (cfg.args.datadir != null) [
                  cfg.args.datadir
                ];
              };

              serviceConfig = {
                User = "geth-${gethName}";
                Group = "geth-${gethName}";

                Restart = "on-failure";
                StateDirectory = statedir;
                SupplementaryGroups = cfg.service.supplementaryGroups;

                # bind custom data dir to /var/lib/... if provided
                BindPaths = lib.lists.optionals (cfg.args.datadir != null) [
                  "${cfg.args.datadir}:${datadir}"
                ];

                # Hardening measures
                CapabilityBoundingSet = "";
                RemoveIPC = "true";
                PrivateTmp = "true";
                ProtectSystem = "full";
                ProtectHome = "read-only";
                ProtectClock = true;
                ProtectProc = "noaccess";
                ProtectKernelLogs = true;
                ProtectKernelModules = true;
                ProtectKernelTunables = true;
                ProtectControlGroups = true;
                ProtectHostname = true;
                NoNewPrivileges = "true";
                PrivateDevices = "true";
                RestrictSUIDSGID = "true";
                RestrictRealtime = true;
                RestrictNamespaces = true;
                LockPersonality = true;
                MemoryDenyWriteExecute = "true";
                SystemCallFilter = ["@system-service" "~@privileged"];
              };

              script = let
                # replace enable flags like --http.enable with just --http
                pathReducer = path: let
                  arg = concatStringsSep "." (lib.lists.remove "enable" path);
                in "--${arg}";

                # filter out certain args which need to be treated differently
                specialArgs = ["network" "datadir"];
                isNormalArg = name: (findFirst (a: a == name) null specialArgs) == null;

                filteredOpts = filterAttrs (n: v: isNormalArg n) gethOpts.options.args;

                # generate flags
                flags = mkFlags {
                  inherit pathReducer;
                  inherit (cfg) args;
                  opts = filteredOpts;
                };

                networkFlag =
                  if cfg.args.network != null
                  then "--${cfg.args.network} \\"
                  else "";
              in ''
                ${cfg.package}/bin/geth \
                    --ipcdisable \
                    ${concatStringsSep " \\\n" flags} \
                    ${networkFlag}
                    --datadir ${datadir} \
                    ${lib.escapeShellArgs cfg.extraArgs}
              '';
            })
      )
      eachGeth;
  };
}
