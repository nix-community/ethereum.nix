{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs' nameValuePair;
  inherit (lib) concatStringsSep filterAttrs mapAttrsToList flatten optionals elem hasAttr;
  inherit (lib.attrsets) zipAttrsWith;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachValidator = config.services.ethereum.lighthouse-validator;
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
            optionals (s.http or false) [(s.http-port or 5062)]
            ++ optionals (s.metrics or true) [(s.metrics-port or 5064)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        name: cfg: let
          user = "lighthouse-${name}";
          serviceName = "lighthouse-validator-${name}";
          s = cfg.settings;
          datadir = s.datadir or "%S/${user}";

          # Keys to skip (handled separately)
          skipKeys = ["datadir" "beacon-nodes" "http" "http-address" "http-port" "metrics" "metrics-address" "metrics-port" "user"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Lighthouse uses space separator
          cliArgs = lib.cli.toGNUCommandLine {} normalSettings;

          # HTTP and metrics flags
          httpArgs = optionals (s.http or false) [
            "--http"
            "--http-address=${s.http-address or "127.0.0.1"}"
            "--http-port=${toString (s.http-port or 5062)}"
          ];
          metricsArgs = optionals (s.metrics or true) [
            "--metrics"
            "--metrics-address=${s.metrics-address or "127.0.0.1"}"
            "--metrics-port=${toString (s.metrics-port or 5064)}"
          ];

          # Beacon nodes: use settings or auto-lookup from lighthouse beacon
          beaconNodes =
            if (s.beacon-nodes or null) != null
            then s.beacon-nodes
            else let
              beaconCfg = config.services.ethereum.lighthouse.${name};
              beaconUrl = "http://${beaconCfg.settings.http-address or "127.0.0.1"}:${toString (beaconCfg.settings.http-port or 5052)}";
            in [beaconUrl];

          allArgs =
            ["--datadir" datadir]
            ++ ["--beacon-nodes" (concatStringsSep "," beaconNodes)]
            ++ cliArgs
            ++ httpArgs
            ++ metricsArgs
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Lighthouse Validator Client (${name})";

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                User = s.user or user;
                StateDirectory = user;
                ExecStart = "${cfg.package}/bin/lighthouse validator ${scriptArgs}";
              }
            ];
          })
      )
      eachValidator;

    assertions =
      mapAttrsToList
      (
        name: cfg: {
          assertion =
            !cfg.enable || (cfg.settings.beacon-nodes or null) != null || (hasAttr name config.services.ethereum.lighthouse);
          message = ''
            Lighthouse Validator ${name} could not find a matching beacon.
            Either set `services.ethereum.lighthouse.${name}` or `services.ethereum.lighthouse-validator.${name}.settings.beacon-nodes`
          '';
        }
      )
      eachValidator;
  };
}
