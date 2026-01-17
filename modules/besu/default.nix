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

  eachNode = config.services.ethereum.besu;
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachNode != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNode;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedTCPPorts =
            [(s.p2p-port or 30303) (s.engine-rpc-port or 8551)]
            ++ optionals (s.rpc-http-enabled or false) [(s.rpc-http-port or 8545)]
            ++ optionals (s.metrics-enabled or false) [(s.metrics-port or 9545)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.tmpfiles.rules =
      map
      (name: "v /var/lib/private/besu-${name}")
      (builtins.attrNames (filterAttrs (_: v: v.subVolume) eachNode));

    systemd.services =
      mapAttrs'
      (
        besuName: cfg: let
          serviceName = "besu-${besuName}";
          s = cfg.settings;
          dataPath = s.data-path or "%S/${serviceName}";
          jwtSecret = s.engine-jwt-secret or null;

          # Keys to skip (handled separately)
          skipKeys = ["data-path" "engine-jwt-secret"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Besu uses = separator
          cliArgs = lib.cli.toGNUCommandLine {
            optionValueSeparator = "=";
          } normalSettings;

          allArgs =
            ["--data-path=${dataPath}"]
            ++ optionals (jwtSecret != null) ["--engine-jwt-secret=%d/jwtsecret"]
            ++ cliArgs
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            description = "Besu Execution Client (${besuName})";
            wantedBy = ["multi-user.target"];
            after = ["network.target"];

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/besu ${scriptArgs}";
                MemoryDenyWriteExecute = false; # JIT compilation
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["jwtsecret:${jwtSecret}"];
              })
            ];
          })
      )
      eachNode;
  };
}
