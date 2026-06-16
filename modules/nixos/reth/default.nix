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
  inherit (builtins) isList isString;
  inherit (modulesLib) baseServiceConfig;

  eachReth = config.services.ethereum.reth;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

  # Parse metrics string "addr:port" to extract port
  parseMetricsPort =
    metricsStr:
    let
      parts = lib.splitString ":" metricsStr;
    in
    if builtins.length parts == 2 then lib.toInt (builtins.elemAt parts 1) else 6060;
in
{
  # Disable the service definition currently in nixpkgs
  disabledModules = [ "services/blockchain/ethereum/reth.nix" ];

  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachReth != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachReth;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
            metricsPort =
              if s.metrics or null != null && isString s.metrics then parseMetricsPort s.metrics else 6060;
          in
          {
            allowedTCPPorts = [
              (s.port or 30303)
            ]
            ++ [ (s."authrpc.port" or 8551) ]
            ++ (optionals (s.http or false) [ (s."http.port" or 8545) ])
            ++ (optionals (s.ws or false) [ (s."ws.port" or 8546) ])
            ++ (optionals (s.metrics or null != null) [ metricsPort ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # configure systemd to create the state directory with a subvolume
    systemd.tmpfiles.rules = map (name: "v /var/lib/private/reth-${name}") (
      builtins.attrNames (filterAttrs (_: v: v.subVolume) eachReth)
    );

    # create a service for each instance
    systemd.services = mapAttrs' (
      rethName:
      let
        serviceName = "reth-${rethName}";
      in
      cfg:
      let
        s = cfg.settings;
        datadir = s.datadir or "%S/${serviceName}";
        jwtSecret = s."authrpc.jwtsecret" or null;

        # Keys that need special handling
        skipKeys = [
          "datadir"
          "authrpc.jwtsecret"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        allArgs = [
          "--log.file.directory"
          "${datadir}/logs"
          "--datadir"
          datadir
        ]
        ++ (optionals (jwtSecret != null) [
          "--authrpc.jwtsecret"
          "%d/jwtsecret"
        ])
        ++ cliArgs
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Reth Ethereum node (${rethName})";

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/reth node ${scriptArgs}";

              # Reth needs this system call for some reason
              SystemCallFilter = [
                "@system-service"
                "~@privileged"
                "mincore"
              ];
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "jwtsecret:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachReth;
  };
}
