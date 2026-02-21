{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../../../lib/modules.nix lib;

  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib)
    concatStringsSep
    filterAttrs
    flatten
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    optionals
    elem
    ;
  inherit (builtins) isList;
  inherit (modulesLib) baseServiceConfig;

  eachBeacon = config.services.ethereum.nimbus-beacon;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

  # Gnosis networks use a different binary
  gnosisNetworks = [
    "gnosis"
    "chiado"
  ];
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachBeacon != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBeacon;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedUDPPorts = [ (s.udp-port or 9000) ];
            allowedTCPPorts = [
              (s.tcp-port or 9000)
            ]
            ++ (optionals (s.rest or false) [ (s.rest-port or 5052) ])
            ++ (optionals (s.metrics or false) [ (s.metrics-port or 5054) ])
            ++ (optionals (s.keymanager or false) [ (s.keymanager-port or 5053) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      beaconName:
      let
        serviceName = "nimbus-beacon-${beaconName}";
      in
      cfg:
      let
        s = cfg.settings;
        dataDir = s.data-dir or "%S/${serviceName}";
        jwtSecret = s.jwt-secret or null;
        trustedNodeUrl = s.trusted-node-url or null;
        network = s.network or beaconName;
        keymanagerTokenFile = s.keymanager-token-file or "api-token.txt";

        # Select appropriate binary based on network
        bin = if elem network gnosisNetworks then "nimbus_beacon_node_gnosis" else "nimbus_beacon_node";

        # Keys that need special handling
        skipKeys = [
          "data-dir"
          "jwt-secret"
          "trusted-node-url"
          "keymanager-token-file"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine with custom separator for Nimbus (--key=value format)
        cliArgs = lib.cli.toGNUCommandLine {
          mkOptionName = k: "--${k}";
        } (processSettings normalSettings);

        allArgs = [
          "--data-dir=${dataDir}"
        ]
        ++ cliArgs
        ++ (optionals (jwtSecret != null) [ "--jwt-secret=%d/jwt-secret" ])
        ++ (optionals (s.keymanager or false) [
          "--keymanager-token-file=${dataDir}/${keymanagerTokenFile}"
        ])
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;

        # Arguments for checkpoint sync (trustedNodeSync)
        checkpointSyncArgs = concatStringsSep " \\\n  " [
          "--backfill=false"
          "--data-dir=${dataDir}"
          "--network=${network}"
          "--trusted-node-url=${trustedNodeUrl}"
        ];
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Nimbus Beacon Node (${beaconName})";

          serviceConfig = mkMerge [
            baseServiceConfig
            {
              # Nimbus requires JIT compilation
              MemoryDenyWriteExecute = false;

              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;

              # Checkpoint download may take longer than the usual 90s default
              TimeoutStartSec = "5min";

              ExecStartPre =
                lib.mkBefore [
                  # Create keymanager token file if it doesn't exist
                  ''
                    ${pkgs.coreutils-full}/bin/cp --no-preserve=all --update=none \
                    /proc/sys/kernel/random/uuid ${dataDir}/${keymanagerTokenFile}''
                ]
                ++ (optionals (trustedNodeUrl != null) [
                  # Run checkpoint sync if trusted-node-url is configured
                  "${cfg.package}/bin/${bin} trustedNodeSync ${checkpointSyncArgs}"
                ]);

              ExecStart = "${cfg.package}/bin/${bin} ${scriptArgs}";

              # Used by doppelganger detection to signal we should NOT restart.
              # https://nimbus.guide/doppelganger-detection.html
              RestartPreventExitStatus = 129;
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "jwt-secret:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachBeacon;
  };
}
