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

  eachValidator = config.services.ethereum.prysm-validator;
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachValidator != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachValidator;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedTCPPorts =
            [(s.grpc-gateway-port or 7500)]
            ++ optionals (s.rpc or false) [(s.rpc-port or 7000)]
            ++ optionals (!(s.disable-monitoring or false)) [(s.monitoring-port or 8081)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        validatorName: cfg: let
          serviceName = "prysm-validator-${validatorName}";
          beaconServiceName = "prysm-${validatorName}";
          s = cfg.settings;
          datadir = s.datadir or "%S/${beaconServiceName}";
          network = s.network or null;

          # Keys to skip (handled separately)
          skipKeys = ["datadir" "network" "rpc" "user"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Prysm uses space separator
          cliArgs = lib.cli.toGNUCommandLine {} normalSettings;

          # RPC flag
          rpcArgs = optionals (s.rpc or false) ["--rpc"];

          # Network flag (--holesky, --sepolia, etc.)
          networkArgs = optionals (network != null) ["--${network}"];

          allArgs =
            ["--accept-terms-of-use"]
            ++ networkArgs
            ++ ["--datadir" datadir]
            ++ cliArgs
            ++ rpcArgs
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Prysm Validator Node (${validatorName})";

            environment = {
              GRPC_GATEWAY_HOST = s.grpc-gateway-host or "127.0.0.1";
              GRPC_GATEWAY_PORT = toString (s.grpc-gateway-port or 7500);
            };

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                User = s.user or beaconServiceName;
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/validator ${scriptArgs}";
                MemoryDenyWriteExecute = "false"; # causes a library loading error
              }
            ];
          })
      )
      eachValidator;
  };
}
