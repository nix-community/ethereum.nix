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

  eachValidator = config.services.ethereum.prysm-validator;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

  # Known network flags that become just --<network>
  networkFlags = [
    "holesky"
    "hoodi"
    "sepolia"
  ];
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachValidator != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachValidator;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedTCPPorts = [
              (s.grpc-gateway-port or 7500)
            ]
            ++ (optionals (s.rpc or false) [ (s.rpc-port or 7000) ])
            ++ (optionals (!(s.disable-monitoring or false)) [ (s.monitoring-port or 8081) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      validatorName:
      let
        serviceName = "prysm-validator-${validatorName}";
        beaconServiceName = "prysm-beacon-${validatorName}";
      in
      cfg:
      let
        s = cfg.settings;
        datadir = s.datadir or "%S/${beaconServiceName}";

        # Keys that need special handling
        skipKeys = [
          "datadir"
          "grpc-gateway-host"
          "grpc-gateway-port"
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
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Prysm Validator Node (${validatorName})";

          environment = {
            GRPC_GATEWAY_HOST = s.grpc-gateway-host or "127.0.0.1";
            GRPC_GATEWAY_PORT = builtins.toString (s.grpc-gateway-port or 7500);
          };

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = if cfg.user != null then cfg.user else beaconServiceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/validator ${scriptArgs}";
              MemoryDenyWriteExecute = "false"; # causes a library loading error
            }
          ];
        }
      )
    ) eachValidator;
  };
}
