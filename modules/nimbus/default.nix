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

  eachNimbus = config.services.ethereum.nimbus;

  # Convert lists to comma-separated, bools to strings
  processSettings = mapAttrs (_: v:
    if isList v then concatStringsSep "," v
    else if isBool v then boolToString v
    else v);
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachNimbus != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNimbus;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedUDPPorts = [(s.udp-port or 9000)];
          allowedTCPPorts =
            [(s.tcp-port or 9000)]
            ++ optionals (s.rest or false) [(s.rest-port or 5052)]
            ++ optionals (s.metrics or true) [(s.metrics-port or 5054)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        nimbusName: cfg: let
          serviceName = "nimbus-${nimbusName}";
          s = cfg.settings;
          dataDir = s.data-dir or "%S/${serviceName}";
          jwtSecret = s.jwt-secret or null;
          trustedNodeUrl = s.trusted-node-url or null;
          network = s.network or "mainnet";

          # Keys to skip (handled separately)
          skipKeys = ["data-dir" "jwt-secret" "trusted-node-url"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Nimbus uses = separator
          cliArgs = lib.cli.toCommandLine (name: {
            option = "--${name}";
            sep = "=";
            explicitBool = false;
          }) (processSettings normalSettings);

          allArgs =
            ["--data-dir=${dataDir}"]
            ++ cliArgs
            ++ optionals (jwtSecret != null) ["--jwt-secret=%d/jwt-secret"]
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;

          # Checkpoint sync args
          checkpointSyncArgs = concatStringsSep " \\\n  " (
            ["--backfill=false" "--data-dir=${dataDir}" "--network=${network}"]
            ++ optionals (trustedNodeUrl != null) ["--trusted-node-url=${trustedNodeUrl}"]
          );

          # Binary selection for gnosis/chiado
          bin = {
            gnosis = "nimbus_beacon_node_gnosis";
            chiado = "nimbus_beacon_node_gnosis";
          }.${network} or "nimbus_beacon_node";
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Nimbus Beacon Node (${nimbusName})";

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                StateDirectory = serviceName;
                ExecStartPre = lib.mkBefore [
                  "${cfg.package}/bin/${bin} trustedNodeSync ${checkpointSyncArgs}"
                ];
                ExecStart = "${cfg.package}/bin/${bin} ${scriptArgs}";
                TimeoutStartSec = "5min";
                MemoryDenyWriteExecute = false; # library loading
                RestartPreventExitStatus = 129; # doppelganger detection
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["jwt-secret:${jwtSecret}"];
              })
            ];
          })
      )
      eachNimbus;
  };
}
