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
    elem
    filterAttrs
    flatten
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    optionals
    ;
  inherit (builtins) isList;
  inherit (modulesLib) baseServiceConfig;

  eachBeacon = config.services.ethereum.lighthouse-beacon;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

  # Known network flags that become just --<network>
  networkFlags = [
    "mainnet"
    "prater"
    "goerli"
    "gnosis"
    "chiado"
    "sepolia"
    "holesky"
    "hoodi"
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
            discoveryPort = s.discovery-port or 9000;
            quicPort = s.quic-port or (discoveryPort + 1);
            disableQuic = s.disable-quic or false;
          in
          {
            allowedUDPPorts = [ discoveryPort ] ++ (optionals (!disableQuic) [ quicPort ]);
            allowedTCPPorts =
              (optionals disableQuic [ quicPort ])
              ++ (optionals (s.http or false) [ (s.http-port or 5052) ])
              ++ (optionals (s.metrics or false) [ (s.metrics-port or 5054) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      beaconName:
      let
        user = "lighthouse-${beaconName}";
        serviceName = "lighthouse-beacon-${beaconName}";
      in
      cfg:
      let
        s = cfg.settings;
        datadir = s.datadir or "%S/${user}";
        jwtSecret = s.execution-jwt or null;

        # Keys that need special handling
        skipKeys = [
          "datadir"
          "execution-jwt"
        ]
        ++ networkFlags;
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        # Handle network flag (just --mainnet, not --network=mainnet for standard networks)
        networkArg =
          let
            activeNetwork = lib.findFirst (n: s.${n} or false) null networkFlags;
            explicitNetwork = s.network or null;
          in
          if activeNetwork != null then
            [ "--${activeNetwork}" ]
          else if explicitNetwork != null then
            [
              "--network"
              explicitNetwork
            ]
          else
            [ ];

        allArgs = [
          "--datadir"
          datadir
        ]
        ++ networkArg
        ++ cliArgs
        ++ (optionals (jwtSecret != null) [
          "--execution-jwt"
          "%d/execution-jwt"
        ])
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Lighthouse Beacon Node (${beaconName})";

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = if cfg.user != null then cfg.user else user;
              StateDirectory = user;
              ExecStart = "${cfg.package}/bin/lighthouse beacon ${scriptArgs}";
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "execution-jwt:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachBeacon;
  };
}
