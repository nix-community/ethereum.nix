{ flake, ... }:
{
  config,
  lib,
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
    mkForce
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

  # Boolean shorthands (`settings.sepolia = true`) for `--network <name>`.
  # Lighthouse has no `--<network>` flags, only `--network <name>`.
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
  imports = [ (lib.modules.importApply ./options.nix { inherit flake; }) ];

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
          "network"
        ]
        ++ networkFlags;
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toCommandLine for RFC 42 settings
        cliArgs = lib.cli.toCommandLine (name: {
          option = "--${name}";
          sep = null;
          explicitBool = false;
        }) (processSettings normalSettings);

        # Emit `--network <name>` once, from either `settings.network` or a
        # boolean shorthand such as `settings.sepolia = true`.
        networkArg =
          let
            activeNetwork = lib.findFirst (n: s.${n} or false) null networkFlags;
            network = if activeNetwork != null then activeNetwork else s.network or null;
          in
          optionals (network != null) [
            "--network"
            network
          ];

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
            (mkIf (cfg.user != null) {
              # A statically-managed user is incompatible with DynamicUser.
              DynamicUser = mkForce false;
            })
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
