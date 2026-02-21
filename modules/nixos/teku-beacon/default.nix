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

  eachBeacon = config.services.ethereum.teku-beacon;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);
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
            allowedUDPPorts = [ (s.p2p-port or 9000) ];
            allowedTCPPorts = [
              (s.p2p-port or 9000)
            ]
            ++ (optionals (s.rest-api-enabled or false) [ (s.rest-api-port or 5051) ])
            ++ (optionals (s.metrics-enabled or false) [ (s.metrics-port or 8008) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      beaconName:
      let
        serviceName = "teku-beacon-${beaconName}";
      in
      cfg:
      let
        s = cfg.settings;
        dataPath = s.data-path or "%S/${serviceName}";
        jwtSecret = s.ee-jwt-secret-file or null;

        # Keys that need special handling
        skipKeys = [
          "data-path"
          "ee-jwt-secret-file"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        allArgs = [
          "--data-path"
          dataPath
        ]
        ++ cliArgs
        ++ (optionals (jwtSecret != null) [
          "--ee-jwt-secret-file"
          "%d/jwt-secret"
        ])
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Teku Beacon Node (${beaconName})";

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/teku ${scriptArgs}";

              # Teku (JVM) requires write+execute for JIT compilation
              MemoryDenyWriteExecute = false;

              # Teku needs this system call for some reason
              SystemCallFilter = [
                "@system-service"
                "~@privileged"
                "mincore"
              ];

              # Used by doppelganger detection to signal we should NOT restart.
              # https://docs.teku.consensys.net/how-to/prevent-slashing/detect-doppelgangers
              RestartPreventExitStatus = 2;
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
