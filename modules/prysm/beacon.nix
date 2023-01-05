{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mdDoc flatten nameValuePair mapAttrs' mapAttrsToList optionalString;
  inherit (lib) literalExpression mkEnableOption mkIf mkOption types;
  inherit (lib.lists) optionals;

  eachBeacon = config.services.prysm.beacon;

  beaconOpts = {
    options = {
      enable = mkEnableOption (mdDoc "Ethereum Beacon Chain Node from Prysmatic Labs");

      dataDir = mkOption {
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

      checkpoint = {
        sync-url = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "URL of a synced beacon node to trust in obtaining checkpoint sync data. As an additional safety measure, it is strongly recommended to only use this option in conjunction with --weak-subjectivity-checkpoint flag";
          example = "https://goerli.checkpoint-sync.ethpandaops.io";
        };
      };

      genesis = {
        beacon-api-url = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "URL of a synced beacon node to trust for obtaining genesis state. As an additional safety measure, it is strongly recommended to only use this option in conjunction with --weak-subjectivity-checkpoint flag";
          example = "https://goerli.checkpoint-sync.ethpandaops.io";
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
            lib.lists.optionals (cfg.dataDir != null) [
              "d ${cfg.dataDir} 0700 prysm-beacon-${beaconName} prysm-beacon-${beaconName} - -"
            ]
        )
        eachBeacon);

    systemd.services =
      mapAttrs'
      (
        beaconName: let
          stateDir = "prysm-beacon-${beaconName}";
          dataDir = "/var/lib/${stateDir}";

          inherit (import ../lib.nix lib) script;
          inherit (script) flag arg optionalArg joinArgs;
        in
          cfg:
            nameValuePair "prysm-beacon-${beaconName}" (mkIf cfg.enable {
              description = "Prysm Beacon Node (${beaconName})";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];

              unitConfig = {
                RequiresMountsFor = optionals (cfg.dataDir != null) [
                  cfg.dataDir
                ];
              };

              serviceConfig = {
                User = "prysm-beacon-${beaconName}";
                Group = "prysm-beacon-${beaconName}";

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
                NoNewPrivileges = "true";
                PrivateDevices = "true";
                RestrictSUIDSGID = "true";
                # MemoryDenyWriteExecute = "true";   causes a library loading error
              };

              script = with cfg;
                joinArgs [
                  "${package}/bin/beacon-chain"
                  "--accept-terms-of-use"
                  (flag network (network != null))
                  (optionalArg "jwt-secret" (jwt-secret != null) jwt-secret)
                  (optionalArg "checkpoint-sync-url" (checkpoint.sync-url != null) checkpoint.sync-url)
                  (optionalArg "genesis-beacon-api-url" (genesis.beacon-api-url != null) genesis.beacon-api-url)
                  (lib.escapeShellArgs extraArgs)
                  (arg "datadir" dataDir)
                ];
            })
      )
      eachBeacon;
  };
}
