{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs' nameValuePair;
  inherit (lib) concatStringsSep filterAttrs mapAttrsToList flatten optionals elem;
  inherit (lib.attrsets) zipAttrsWith;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachTeku = config.services.ethereum.teku;
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachTeku != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachTeku;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedUDPPorts = [(s.p2p-port or 9000)];
          allowedTCPPorts =
            [(s.p2p-port or 9000)]
            ++ optionals (s.rest-api-enabled or false) [(s.rest-api-port or 5051)]
            ++ optionals (s.metrics-enabled or true) [(s.metrics-port or 8008)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        tekuName: cfg: let
          serviceName = "teku-${tekuName}";
          s = cfg.settings;
          dataPath = s.data-path or "%S/${serviceName}";
          jwtSecret = s.ee-jwt-secret-file or null;

          # Keys to skip (handled separately)
          skipKeys = ["data-path" "ee-jwt-secret-file"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Teku uses = separator
          cliArgs =
            lib.cli.toCommandLine (name: {
              option = "--${name}";
              sep = "=";
              explicitBool = false;
            })
            normalSettings;

          allArgs =
            ["--data-path=${dataPath}"]
            ++ cliArgs
            ++ optionals (jwtSecret != null) ["--ee-jwt-secret-file=%d/jwt-secret"]
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Teku Beacon Node (${tekuName})";

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/teku ${scriptArgs}";
                SystemCallFilter = ["@system-service" "~@privileged" "mincore"];
                MemoryDenyWriteExecute = false; # JVM
                RestartPreventExitStatus = 2;
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["jwt-secret:${jwtSecret}"];
              })
            ];
          })
      )
      eachTeku;
  };
}
