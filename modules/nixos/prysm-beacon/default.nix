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

  eachBeacon = config.services.ethereum.prysm-beacon;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

  # Known network flags that become just --<network>
  networkFlags = [
    "mainnet"
    "holesky"
    "hoodi"
    "sepolia"
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
            allowedUDPPorts = [ (s.p2p-udp-port or 12000) ];
            allowedTCPPorts = [
              (s.p2p-tcp-port or 13000)
            ]
            ++ [ (s.rpc-port or 4000) ]
            ++ (optionals (!(s.disable-monitoring or false)) [ (s.monitoring-port or 8080) ])
            ++ (optionals (!(s.disable-grpc-gateway or false)) [ (s.grpc-gateway-port or 3500) ])
            ++ (optionals (s.pprof or false) [ (s.pprofport or 6060) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      beaconName:
      let
        serviceName = "prysm-beacon-${beaconName}";
      in
      cfg:
      let
        s = cfg.settings;
        datadir = s.datadir or "%S/${serviceName}";
        jwtSecret = s.jwt-secret or null;

        # Keys that need special handling
        skipKeys = [
          "datadir"
          "jwt-secret"
        ]
        ++ networkFlags;
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        # Handle network flag (just --sepolia, not --sepolia=true)
        networkArg =
          let
            activeNetwork = lib.findFirst (n: s.${n} or false) null networkFlags;
          in
          optionals (activeNetwork != null) [ "--${activeNetwork}" ];

        allArgs = [
          "--accept-terms-of-use"
          "--datadir"
          datadir
        ]
        ++ networkArg
        ++ cliArgs
        ++ (optionals (jwtSecret != null) [
          "--jwt-secret"
          "%d/jwt-secret"
        ])
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Prysm Beacon Node (${beaconName})";

          environment = {
            GRPC_GATEWAY_HOST = s.grpc-gateway-host or "127.0.0.1";
            GRPC_GATEWAY_PORT = builtins.toString (s.grpc-gateway-port or 3500);
          };

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/beacon-chain ${scriptArgs}";
              MemoryDenyWriteExecute = "false"; # causes a library loading error
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
