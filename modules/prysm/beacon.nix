{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) literalExpression mkEnableOption mkIf mkOption types optionalString;
  inherit (lib) mdDoc flatten nameValuePair mapAttrs' filterAttrsRecursive mapAttrsToList;
  inherit (lib.lists) optionals;

  settingsFormat = pkgs.formats.yaml {};

  eachBeacon = config.services.prysm.beacon;

  beaconOpts = {
    options = {
      enable = mkEnableOption (mdDoc "Ethereum Beacon Chain Node from Prysmatic Labs");

      settings = {
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
          description = "URL of a synced beacon node to trust in obtaining checkpoint sync data. As an additional safety measure, it is strongly recommended to only use this option in conjunction with --weak-subjectivity-checkpoint flag";
          example = "https://goerli.checkpoint-sync.ethpandaops.io";
        };

        genesis-beacon-api-url = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "URL of a synced beacon node to trust for obtaining genesis state. As an additional safety measure, it is strongly recommended to only use this option in conjunction with --weak-subjectivity-checkpoint flag";
          example = "https://goerli.checkpoint-sync.ethpandaops.io";
        };
      };

      extraSettings = mkOption {
        type = settingsFormat.type;
        default = {};
        description = mdDoc "Additional settings to pass to Prysm Beacon Chain.";
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
            lib.lists.optionals (cfg.settings.datadir != null) [
              "d ${cfg.settings.datadir} 0700 prysm-beacon-${beaconName} prysm-beacon-${beaconName} - -"
            ]
        )
        eachBeacon);

    systemd.services =
      mapAttrs'
      (
        beaconName: let
          stateDir = "prysm-beacon-${beaconName}";
          datadir = "/var/lib/${stateDir}";

          inherit (import ../lib.nix {inherit lib pkgs;}) script;
          inherit (script) flag arg optionalArg joinArgs;
        in
          cfg:
            nameValuePair "prysm-beacon-${beaconName}" (mkIf cfg.enable {
              description = "Prysm Beacon Node (${beaconName})";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];

              unitConfig = {
                RequiresMountsFor = optionals (cfg.settings.datadir != null) [
                  cfg.settings.datadir
                ];
              };

              serviceConfig = {
                User = "prysm-beacon-${beaconName}";
                Group = "prysm-beacon-${beaconName}";

                Restart = "on-failure";
                StateDirectory = stateDir;
                SupplementaryGroups = cfg.service.supplementaryGroups;

                # bind custom data dir to /var/lib/... if provided
                BindPaths = lib.lists.optionals (cfg.settings.datadir != null) [
                  "${cfg.settings.datadir}:${datadir}"
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

              script = with cfg; let
                # filter null values and merge with extra settings
                settings = (filterAttrsRecursive (_: v: v != null) cfg.settings) // cfg.extraSettings;
                # generate the yaml config file
                configFile = settingsFormat.generate "config.yaml" settings;
              in ''
                ${cfg.package}/bin/beacon-chain \
                    --accept-terms-of-use \
                    --${settings.network} \
                    --config-file ${configFile} \
                    ${lib.escapeShellArgs extraArgs}
              '';
            })
      )
      eachBeacon;
  };
}
