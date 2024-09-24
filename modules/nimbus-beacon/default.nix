{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix lib;

  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib.trivial) boolToString;
  inherit
    (builtins)
    isBool
    isList
    toString
    ;
  inherit
    (lib)
    concatStringsSep
    filterAttrs
    flatten
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    ;
  inherit (modulesLib) mkArgs baseServiceConfig;

  eachBeacon = config.services.ethereum.nimbus-beacon;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachBeacon != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBeacon;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [udp-port];
              allowedTCPPorts =
                [tcp-port]
                ++ (optionals rest.enable [rest.port])
                ++ (optionals metrics.enable [metrics.port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        beaconName: let
          user = "nimbus-beacon-${beaconName}";
          serviceName = "nimbus-beacon-${beaconName}";
        in
          cfg: let
            args = mkArgs {
              inherit (cfg) args;
              opts = import ./args.nix {
                inherit lib;
                name = beaconName;
                config = cfg;
              };
              argReducer = value:
                if (isList value)
                then concatStringsSep "," value
                else if (isBool value)
                then boolToString value
                else toString value;
              # custom arg formatter for nimbus
              argFormatter = {
                path,
                value,
                argReducer,
                pathReducer,
                ...
              }: let
                arg = pathReducer path;
              in
                if (value == null)
                then ""
                else "${arg}=${argReducer value}";
            };

            jwt-secret =
              if cfg.args.jwt-secret != null
              then "--jwt-secret=%d/jwt-secret"
              else "";
            data-dir =
              if cfg.args.data-dir != null
              then cfg.args.data-dir
              else "%S/${serviceName}";
            data-dir-arg = "--data-dir=${data-dir}";

            scriptArgs = let
              # filter out certain args which need to be treated differently
              specialArgs = [
                "--jwt-secret"
                "--data-dir"
                "--user" # Not a CLI Flag, only used in systemd service
                "--rest-enable"
                "--rest-address"
                "--rest-port"
                "--rest-allow-origin"
                "--metrics-enable"
                "--metrics-address"
                "--metrics-port"
                "--payload-builder-enable"
                "--payload-builder-url"
                "--keymanager-enable"
                "--keymanager-token-file"
                "--keymanager-address"
                "--keymanager-port"
                "--trusted-node-url" # only needed for checkpoint sync
              ];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
              filteredArgs =
                (builtins.filter isNormalArg args)
                ++ (optionals cfg.args.rest.enable [
                  "--rest"
                  "--rest-address=${cfg.args.rest.address}"
                  "--rest-port=${toString cfg.args.rest.port}"
                ])
                ++ (optionals (cfg.args.rest.allow-origin != null) [
                  "--rest-allow-origin=${cfg.args.rest.allow-origin}"
                ])
                ++ (optionals cfg.args.metrics.enable [
                  "--metrics"
                  "--metrics-address=${cfg.args.metrics.address}"
                  "--metrics-port=${toString cfg.args.metrics.port}"
                ])
                ++ (optionals cfg.args.payload-builder.enable [
                  "--payload-builder"
                  "--payload-builder-url=${cfg.args.payload-builder.url}"
                ])
                ++ (optionals cfg.args.keymanager.enable [
                  "--keymanager"
                  "--keymanager-address=${cfg.args.keymanager.address}"
                  "--keymanager-port=${toString cfg.args.keymanager.port}"
                  "--keymanager-token-file=${data-dir}/${cfg.args.keymanager.token-file}"
                ]);
            in ''
              ${jwt-secret} \
              ${data-dir-arg} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
            checkpointSyncArgs = let
              # Filter to only include args needed for checkpoint sync
              checkpointArgs = [
                "--network"
                "--trusted-node-url"
              ];
              isCheckpointArg = name: (findFirst (arg: hasPrefix arg name) null checkpointArgs) != null;
              filteredArgs = builtins.filter isCheckpointArg args;
            in ''
              --backfill=false \
              ${data-dir-arg} \
              ${concatStringsSep " \\\n" filteredArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Nimbus Beacon Node (${beaconName})";

              serviceConfig = mkMerge [
                {
                  MemoryDenyWriteExecute = false;
                  User =
                    if cfg.args.user != null
                    then cfg.args.user
                    else user;
                  StateDirectory = user;
                  ExecStartPre = lib.mkBefore [
                    ''                      ${pkgs.coreutils-full}/bin/cp --no-preserve=all --update=none \
                      /proc/sys/kernel/random/uuid ${data-dir}/${cfg.args.keymanager.token-file}''
                    "${cfg.package}/bin/nimbus_beacon_node trustedNodeSync ${checkpointSyncArgs}"
                  ];
                  ExecStart = "${cfg.package}/bin/nimbus_beacon_node ${scriptArgs}";
                }
                baseServiceConfig
                (mkIf (cfg.args.jwt-secret != null) {
                  LoadCredential = ["jwt-secret:${cfg.args.jwt-secret}"];
                })
              ];
            })
      )
      eachBeacon;
  };
}
