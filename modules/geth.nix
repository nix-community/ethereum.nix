/*
* Derived from https://github.com/NixOS/nixpkgs/blob/45b92369d6fafcf9e462789e98fbc735f23b5f64/nixos/modules/services/blockchain/ethereum/geth.nix
*/
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mdDoc flatten nameValuePair filterAttrs mapAttrs mapAttrs' mapAttrsToList;
  inherit (lib) optionalString literalExpression mkEnableOption mkIf mkOption types;
  inherit (lib.lists) optionals;

  eachGeth = config.services.geth;

  gethOpts = {
    options = {
      enable = mkEnableOption (mdDoc "Go Ethereum Node");

      dataDir = mkOption {
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
        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = mdDoc "Listen address of Go Ethereum HTTP API.";
        };

        port = mkOption {
          type = types.port;
          default = 8545;
          description = mdDoc "Port number of Go Ethereum HTTP API.";
        };

        apis = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
          description = mdDoc "APIs to enable over HTTP";
          example = ["net" "eth"];
        };
      };

      websocket = {
        enable = mkEnableOption (mdDoc "Go Ethereum WebSocket API");
        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = mdDoc "Listen address of Go Ethereum WebSocket API.";
        };

        port = mkOption {
          type = types.port;
          default = 8546;
          description = mdDoc "Port number of Go Ethereum WebSocket API.";
        };

        apis = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
          description = mdDoc "APIs to enable over WebSocket";
          example = ["net" "eth"];
        };
      };

      authrpc = {
        enable = mkEnableOption (mdDoc "Go Ethereum Auth RPC API");
        address = mkOption {
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
          type = types.nullOr (types.listOf types.str);
          default = ["localhost"];
          description = mdDoc "List of virtual hostnames from which to accept requests.";
          example = ["localhost" "geth.example.org"];
        };

        jwtsecret = mkOption {
          type = types.str;
          default = "";
          description = mdDoc "Path to a JWT secret for authenticated RPC endpoint.";
          example = "/var/run/geth/jwtsecret";
        };
      };

      metrics = {
        enable = mkEnableOption (mdDoc "Go Ethereum prometheus metrics");
        address = mkOption {
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
        type = types.nullOr (types.enum ["goerli" "rinkeby" "yolov2" "ropsten"]);
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
            lib.lists.optionals (cfg.dataDir != null) [
              "d ${cfg.dataDir} 0700 geth-${gethName} geth-${gethName} - -"
            ]
        )
        eachGeth);

    # configure the firewall for each service
    networking.firewall.allowedTCPPorts = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachGeth;
      perService =
        mapAttrsToList
        (
          _: cfg:
            [cfg.port cfg.authrpc.port]
            ++ (optionals cfg.http.enable [cfg.http.port])
            ++ (optionals cfg.websocket.enable [cfg.websocket.port])
            ++ (optionals cfg.metrics.enable [cfg.metrics.port])
        )
        openFirewall;
    in
      flatten perService;

    # create a service for each instance
    systemd.services =
      mapAttrs'
      (
        gethName: let
          stateDir = "geth-${gethName}";
          dataDir = "/var/lib/${stateDir}";
        in
          cfg:
            nameValuePair "geth-${gethName}" (mkIf cfg.enable {
              description = "Go Ethereum node (${gethName})";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];

              unitConfig = {
                RequiresMountsFor = optionals (cfg.dataDir != null) [
                  cfg.dataDir
                ];
              };

              serviceConfig = {
                User = "geth-${gethName}";
                Group = "geth-${gethName}";

                Restart = "always";
                StateDirectory = stateDir;
                SupplementaryGroups = cfg.service.supplementaryGroups;

                # bind custom data dir to /var/lib/... if provided
                BindPaths = lib.lists.optionals (cfg.dataDir != null) [
                  "${cfg.dataDir}:${dataDir}"
                ];

                # Hardening measures
                RemoveIPC = "true";
                PrivateTmp = "true";
                ProtectSystem = "full";
                ProtectHome = "read-only";
                NoNewPrivileges = "true";
                PrivateDevices = "true";
                RestrictSUIDSGID = "true";
                MemoryDenyWriteExecute = "true";
              };

              script = ''
                ${cfg.package}/bin/geth \
                --nousb \
                --ipcdisable \
                ${optionalString (cfg.network != null) ''--${cfg.network}''} \
                --syncmode ${cfg.syncmode} \
                --gcmode ${cfg.gcmode} \
                --port ${toString cfg.port} \
                --maxpeers ${toString cfg.maxpeers} \
                ${
                  if cfg.http.enable
                  then ''--http --http.addr ${cfg.http.address} --http.port ${toString cfg.http.port}''
                  else ""
                } \
                ${optionalString (cfg.http.apis != null) ''--http.api ${lib.concatStringsSep "," cfg.http.apis}''} \
                ${
                  if cfg.websocket.enable
                  then ''--ws --ws.addr ${cfg.websocket.address} --ws.port ${toString cfg.websocket.port}''
                  else ""
                } \
                ${optionalString (cfg.websocket.apis != null) ''--ws.api ${lib.concatStringsSep "," cfg.websocket.apis}''} \
                ${optionalString cfg.metrics.enable ''--metrics --metrics.addr ${cfg.metrics.address} --metrics.port ${toString cfg.metrics.port}''} \
                --authrpc.addr ${cfg.authrpc.address} --authrpc.port ${toString cfg.authrpc.port} --authrpc.vhosts ${lib.concatStringsSep "," cfg.authrpc.vhosts} \
                ${
                  if (cfg.authrpc.jwtsecret != "")
                  then ''--authrpc.jwtsecret ${cfg.authrpc.jwtsecret}''
                  else ''--authrpc.jwtsecret ${stateDir}/jwtsecret''
                } \
                ${lib.escapeShellArgs cfg.extraArgs} \
                --datadir ${dataDir}
              '';
            })
      )
      eachGeth;
  };
}
