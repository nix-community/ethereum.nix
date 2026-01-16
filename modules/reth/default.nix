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

  eachReth = config.services.ethereum.reth;

in {
  disabledModules = ["services/blockchain/ethereum/reth.nix"];

  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachReth != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachReth;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedTCPPorts =
            [(s.port or 30303) (s."authrpc.port" or 8551)]
            ++ optionals (s.http or false) [(s."http.port" or 8545)]
            ++ optionals (s.ws or false) [(s."ws.port" or 8546)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.tmpfiles.rules =
      map
      (name: "v /var/lib/private/reth-${name}")
      (builtins.attrNames (filterAttrs (_: v: v.subVolume) eachReth));

    systemd.services =
      mapAttrs'
      (
        rethName: cfg: let
          serviceName = "reth-${rethName}";
          s = cfg.settings;
          datadir = s.datadir or "%S/${serviceName}";
          jwtSecret = s."authrpc.jwtsecret" or null;

          # Keys to skip (handled separately)
          skipKeys = ["datadir" "authrpc.jwtsecret"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Standard lib.cli
          cliArgs = lib.cli.toCommandLine (name: {
            option = "--${name}";
            sep = null;
            explicitBool = false;
          }) normalSettings;

          allArgs =
            ["--datadir" datadir]
            ++ cliArgs
            ++ optionals (jwtSecret != null) ["--authrpc.jwtsecret" "%d/jwtsecret"]
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            description = "Reth Ethereum node (${rethName})";
            wantedBy = ["multi-user.target"];
            after = ["network.target"];

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                User = serviceName;
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/reth node ${scriptArgs}";
                SystemCallFilter = ["@system-service" "~@privileged" "mincore"];
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["jwtsecret:${jwtSecret}"];
              })
            ];
          })
      )
      eachReth;
  };
}
