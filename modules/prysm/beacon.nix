{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) literalExpression mkEnableOption mkIf mkOption types optionalString;
  inherit (lib) mdDoc flatten nameValuePair zipAttrsWith mapAttrs' filterAttrsRecursive mapAttrsToList filterAttrs;
  inherit (lib.lists) optionals findFirst;
  inherit (builtins) concatStringsSep;

  settingsFormat = pkgs.formats.yaml {};

  eachBeacon = config.services.prysm.beacon;

  beaconOpts = {
    options = {
      enable = mkEnableOption (mdDoc "Ethereum Beacon Chain Node from Prysmatic Labs");

      args = {
        datadir = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = mdDoc "Data directory for the databases";
          example = "/data/ethereum/goerli/prysm-beacon";
        };

        network = mkOption {
          type = types.nullOr (types.enum ["goerli" "prater" "ropsten" "sepolia"]);
          default = null;
          description = mdDoc "The network to connect to. Mainnet (null) is the default ethereum network.";
        };

        jwt-secret = mkOption {
          type = types.str;
          default = null;
          description = mdDoc "Path to a file containing a hex-encoded string representing a 32 byte secret used for authentication with an execution node via HTTP";
          example = "/var/run/prysm/jwtsecret";
        };

        checkpoint-sync-url = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = mdDoc "URL of a synced beacon node to trust in obtaining checkpoint sync data. As an additional safety measure, it is strongly recommended to only use this option in conjunction with --weak-subjectivity-checkpoint flag";
          example = "https://goerli.checkpoint-sync.ethpandaops.io";
        };

        genesis-beacon-api-url = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = mdDoc "URL of a synced beacon node to trust for obtaining genesis state. As an additional safety measure, it is strongly recommended to only use this option in conjunction with --weak-subjectivity-checkpoint flag";
          example = "https://goerli.checkpoint-sync.ethpandaops.io";
        };

        p2p-udp-port = mkOption {
          type = types.port;
          default = 12000;
          description = mdDoc "The port used by discv5.";
        };

        p2p-tcp-port = mkOption {
          type = types.port;
          default = 13000;
          description = mdDoc "The port used by libp2p.";
        };

        disable-monitoring = mkOption {
          type = types.bool;
          default = false;
          description = mdDoc "Disable monitoring service.";
        };

        monitoring-host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = mdDoc "Host used to listen and respond with metrics for prometheus.";
        };

        monitoring-port = mkOption {
          type = types.port;
          default = 8080;
          description = mdDoc "Port used to listen and respond with metrics for prometheus.";
        };

        disable-grpc-gateway = mkOption {
          type = types.bool;
          default = false;
          description = mdDoc "Disable the gRPC gateway for JSON-HTTP requests ";
        };

        grpc-gateway-host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = mdDoc "The host on which the gateway server runs on.";
        };

        grpc-gateway-port = mkOption {
          type = types.port;
          default = 3500;
          description = mdDoc "The port on which the gateway server runs.";
        };

        rpc-host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = mdDoc "Host on which the RPC server should listen.";
        };

        rpc-port = mkOption {
          type = types.port;
          default = 4000;
          description = mdDoc "RPC port exposed by a beacon node.";
        };

        pprof = mkOption {
          type = types.bool;
          default = false;
          description = mdDoc "Enable the pprof HTTP server.";
        };

        pprofaddr = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = mdDoc "pprof HTTP server listening interface.";
        };

        pprofport = mkOption {
          type = types.port;
          default = 6060;
          description = mdDoc "pprof HTTP server listening port.";
        };
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Prysm Beacon Chain.";
        default = [];
      };

      package = mkOption {
        default = pkgs.prysm;
        defaultText = literalExpression "pkgs.prysm";
        type = types.package;
        description = mdDoc "Package to use for Prysm binary";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
      };

      service = {
        supplementaryGroups = mkOption {
          default = [];
          type = types.listOf types.str;
          description = mdDoc "Additional groups for the systemd service e.g. sops-nix group for secret access";
        };
      };
    };
  };
in {
  ###### interface

  options = {
    services.prysm.beacon = mkOption {
      type = types.attrsOf (types.submodule beaconOpts);
      default = {};
      description = mdDoc "Specification of one or more prysm beacon chain instances.";
    };
  };

  ###### implementation

  config = mkIf (eachBeacon != {}) {
    # collect packages and add them to the system
    environment.systemPackages = flatten (mapAttrsToList
      (_: cfg: [
        cfg.package
      ])
      eachBeacon);

    # add a group for each instance
    users.groups =
      mapAttrs'
      (beaconName: _: nameValuePair "prysm-beacon-${beaconName}" {})
      eachBeacon;

    # add a system user for each instance
    users.users =
      mapAttrs'
      (beaconName: _:
        nameValuePair "prysm-beacon-${beaconName}" {
          isSystemUser = true;
          group = "prysm-beacon-${beaconName}";
          description = "System user for prysm beacon chain ${beaconName} instance";
        })
      eachBeacon;

    # ensure data directories are created and have the correct permissions for any instances that specify one
    systemd.tmpfiles.rules =
      lib.lists.flatten
      (mapAttrsToList
        (
          beaconName: cfg:
            lib.lists.optionals (cfg.args.datadir != null) [
              "d ${cfg.args.datadir} 0700 prysm-beacon-${beaconName} prysm-beacon-${beaconName} - -"
            ]
        )
        eachBeacon);

    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBeacon;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [p2p-udp-port];
              allowedTCPPorts =
                [rpc-port p2p-tcp-port]
                ++ (optionals (disable-monitoring == false) [monitoring-port])
                ++ (optionals (disable-grpc-gateway == false) [grpc-gateway-port])
                ++ (optionals pprof [pprofport]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (name: vals: flatten vals) perService;

    systemd.services =
      mapAttrs'
      (
        beaconName: let
          stateDir = "prysm-beacon-${beaconName}";
          datadir = "/var/lib/${stateDir}";

          modulesLib = import ../lib.nix {inherit lib pkgs;};
          inherit (modulesLib.flags) mkFlags;
        in
          cfg:
            nameValuePair "prysm-beacon-${beaconName}" (mkIf cfg.enable {
              description = "Prysm Beacon Node (${beaconName})";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];

              unitConfig = {
                RequiresMountsFor = optionals (cfg.args.datadir != null) [
                  cfg.args.datadir
                ];
              };

              serviceConfig = {
                User = "prysm-beacon-${beaconName}";
                Group = "prysm-beacon-${beaconName}";

                Restart = "on-failure";
                StateDirectory = stateDir;
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
                ProcSubset = "pid";
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
                SystemCallFilter = ["@system-service" "~@privileged"];
                # MemoryDenyWriteExecute = "true";   causes a library loading error
              };

              script = let
                # filter out certain args which need to be treated differently
                specialArgs = ["network" "datadir"];
                isNormalArg = name: (findFirst (a: a == name) null specialArgs) == null;

                filteredOpts = filterAttrs (n: v: isNormalArg n) beaconOpts.options.args;

                # generate flags
                flags = mkFlags {
                  opts = filteredOpts;
                  args = cfg.args;
                };

                networkFlag =
                  if cfg.args.network != null
                  then "--${cfg.args.network} \\"
                  else "";
              in ''
                ${cfg.package}/bin/beacon-chain \
                    --accept-terms-of-use \
                    ${concatStringsSep " \\\n" flags} \
                    ${networkFlag}
                    --datadir ${datadir} \
                    ${lib.escapeShellArgs cfg.extraArgs}
              '';
            })
      )
      eachBeacon;
  };
}
