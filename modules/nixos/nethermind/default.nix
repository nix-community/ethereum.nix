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
    boolToString
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
  inherit (builtins) isBool isList toString;
  inherit (modulesLib) baseServiceConfig;

  eachNethermind = config.services.ethereum.nethermind;

  # Convert settings to CLI arguments for Nethermind
  # Nethermind uses space-separated args: --Key value (not --Key=value)
  processSettings = mapAttrs (
    _: v:
    if isList v then
      concatStringsSep "," v
    else if isBool v then
      boolToString v
    else
      toString v
  );

  # Convert settings to Nethermind CLI format
  toNethermindArgs =
    settings:
    let
      processed = processSettings settings;
    in
    flatten (
      mapAttrsToList (name: value: [
        "--${name}"
        value
      ]) processed
    );
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachNethermind != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNethermind;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedUDPPorts = [ (s."Network.DiscoveryPort" or 30303) ];
            allowedTCPPorts = [
              (s."Network.P2PPort" or 30303)
              (s."JsonRpc.EnginePort" or 8551)
            ]
            ++ (optionals (s."JsonRpc.Enabled" or true) [
              (s."JsonRpc.Port" or 8545)
              (s."JsonRpc.WebSocketsPort" or 8545)
            ])
            ++ (optionals ((s."Metrics.Enabled" or true) && (s."Metrics.ExposePort" or null) != null) [
              s."Metrics.ExposePort"
            ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      nethermindName:
      let
        serviceName = "nethermind-${nethermindName}";
      in
      cfg:
      let
        s = cfg.settings;
        datadir = s.datadir or "%S/${serviceName}";
        jwtSecret = s."JsonRpc.JwtSecretFile" or null;

        # Keys that need special handling
        skipKeys = [
          "datadir"
          "JsonRpc.JwtSecretFile"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Build CLI arguments
        cliArgs = toNethermindArgs normalSettings;

        allArgs = [
          "--datadir"
          datadir
        ]
        ++ cliArgs
        ++ (optionals (jwtSecret != null) [
          "--JsonRpc.JwtSecretFile"
          "%d/jwtsecret"
        ])
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Nethermind Node (${nethermindName})";

          environment = {
            WEB3_HTTP_HOST = s."JsonRpc.Host" or "127.0.0.1";
            WEB3_HTTP_PORT = builtins.toString (s."JsonRpc.Port" or 8545);
          };

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              MemoryDenyWriteExecute = false; # setting this option is incompatible with JIT
              ExecStart = "${cfg.package}/bin/nethermind ${scriptArgs}";
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "jwtsecret:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachNethermind;
  };
}
