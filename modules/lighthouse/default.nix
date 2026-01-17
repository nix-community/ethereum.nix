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

  eachLighthouse = config.services.ethereum.lighthouse;
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachLighthouse != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachLighthouse;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedUDPPorts =
            [(s.discovery-port or 9000)]
            ++ optionals (!(s.disable-quic or false)) [(s.quic-port or 9001)];
          allowedTCPPorts =
            optionals (s.disable-quic or false) [(s.quic-port or 9001)]
            ++ optionals (s.http or false) [(s.http-port or 5052)]
            ++ optionals (s.metrics or false) [(s.metrics-port or 5054)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        lighthouseName: cfg: let
          serviceName = "lighthouse-${lighthouseName}";
          s = cfg.settings;
          datadir = s.datadir or "%S/${serviceName}";
          jwtSecret = s.execution-jwt or null;

          # Keys to skip (handled separately)
          skipKeys = ["datadir" "execution-jwt"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Standard lib.cli
          cliArgs =
            lib.cli.toCommandLine (name: {
              option = "--${name}";
              sep = null;
              explicitBool = false;
            })
            normalSettings;

          allArgs =
            ["--datadir" datadir]
            ++ cliArgs
            ++ optionals (jwtSecret != null) ["--execution-jwt" "%d/execution-jwt"]
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Lighthouse Beacon Node (${lighthouseName})";

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/lighthouse beacon ${scriptArgs}";
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["execution-jwt:${jwtSecret}"];
              })
            ];
          })
      )
      eachLighthouse;
  };
}
