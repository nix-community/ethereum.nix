{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs' nameValuePair;
  inherit (lib) concatStringsSep filterAttrs mapAttrsToList flatten optionals elem mapAttrs;
  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib.trivial) boolToString;
  inherit (builtins) isList isBool toString;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachNethermind = config.services.ethereum.nethermind;

  # Convert lists to comma-separated, bools to strings
  processSettings = mapAttrs (_: v:
    if isList v then concatStringsSep "," v
    else if isBool v then boolToString v
    else v);
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachNethermind != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNethermind;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedUDPPorts = [(s."Network.DiscoveryPort" or 30303)];
          allowedTCPPorts =
            [(s."Network.P2PPort" or 30303) (s."JsonRpc.EnginePort" or 8551)]
            ++ optionals (s."JsonRpc.Enabled" or true) [(s."JsonRpc.Port" or 8545) (s."JsonRpc.WebSocketsPort" or 8545)]
            ++ optionals ((s."Metrics.Enabled" or true) && (s."Metrics.ExposePort" or null) != null) [(s."Metrics.ExposePort")];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        nethermindName: cfg: let
          serviceName = "nethermind-${nethermindName}";
          s = cfg.settings;
          datadir = s.datadir or "%S/${serviceName}";
          jwtSecret = s."JsonRpc.JwtSecretFile" or null;

          # Keys to skip (handled separately)
          skipKeys = ["datadir" "JsonRpc.JwtSecretFile"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Nethermind uses space separator
          cliArgs = lib.cli.toGNUCommandLine {} (processSettings normalSettings);

          allArgs =
            ["--datadir" datadir]
            ++ cliArgs
            ++ optionals (jwtSecret != null) ["--JsonRpc.JwtSecretFile" "%d/jwtsecret"]
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Nethermind Node (${nethermindName})";

            environment = {
              WEB3_HTTP_HOST = s."JsonRpc.Host" or "127.0.0.1";
              WEB3_HTTP_PORT = toString (s."JsonRpc.Port" or 8545);
            };

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                MemoryDenyWriteExecute = false; # incompatible with JIT
                User = serviceName;
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/nethermind ${scriptArgs}";
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["jwtsecret:${jwtSecret}"];
              })
            ];
          })
      )
      eachNethermind;
  };
}
