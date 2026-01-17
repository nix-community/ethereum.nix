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

  eachPrysm = config.services.ethereum.prysm;
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachPrysm != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachPrysm;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedUDPPorts = [(s.p2p-udp-port or 12000)];
          allowedTCPPorts =
            [(s.rpc-port or 4000) (s.p2p-tcp-port or 13000)]
            ++ optionals (!(s.disable-monitoring or false)) [(s.monitoring-port or 8080)]
            ++ optionals (!(s.disable-grpc-gateway or false)) [(s.grpc-gateway-port or 3500)]
            ++ optionals (s.pprof or false) [(s.pprofport or 6060)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        prysmName: cfg: let
          serviceName = "prysm-${prysmName}";
          s = cfg.settings;
          datadir = s.datadir or "%S/${serviceName}";
          jwtSecret = s.jwt-secret or null;

          # Keys to skip (handled separately)
          skipKeys = ["datadir" "jwt-secret"];
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
            ["--accept-terms-of-use" "--datadir" datadir]
            ++ cliArgs
            ++ optionals (jwtSecret != null) ["--jwt-secret" "%d/jwt-secret"]
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Prysm Beacon Node (${prysmName})";

            environment = {
              GRPC_GATEWAY_HOST = s.grpc-gateway-host or "127.0.0.1";
              GRPC_GATEWAY_PORT = toString (s.grpc-gateway-port or 3500);
            };

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/beacon-chain ${scriptArgs}";
                MemoryDenyWriteExecute = "false"; # library loading
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["jwt-secret:${jwtSecret}"];
              })
            ];
          })
      )
      eachPrysm;
  };
}
