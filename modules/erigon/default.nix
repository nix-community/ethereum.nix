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

  eachErigon = config.services.ethereum.erigon;
in {
  disabledModules = ["services/blockchain/ethereum/erigon.nix"];

  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachErigon != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachErigon;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedUDPPorts = [(s.port or 30303) (s."torrent.port" or 42069)];
          allowedTCPPorts =
            [(s.port or 30303) (s."authrpc.port" or 8551) (s."torrent.port" or 42069)]
            ++ optionals (s.http or false) [(s."http.port" or 8545)]
            ++ optionals (s.ws or false) [(s."http.port" or 8545)]
            ++ optionals (s.metrics or false) [(s."metrics.port" or 6060)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.tmpfiles.rules =
      map
      (name: "v /var/lib/private/erigon-${name}")
      (builtins.attrNames (filterAttrs (_: v: v.subVolume) eachErigon));

    systemd.services =
      mapAttrs'
      (
        erigonName: cfg: let
          serviceName = "erigon-${erigonName}";
          s = cfg.settings;
          datadir = s.datadir or "%S/${serviceName}";
          jwtSecret = s."authrpc.jwtsecret" or null;

          # Keys to skip (handled separately)
          skipKeys = ["datadir" "authrpc.jwtsecret"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Erigon uses space separator
          cliArgs = lib.cli.toGNUCommandLine {} normalSettings;

          allArgs =
            ["--datadir" datadir]
            ++ optionals (jwtSecret != null) ["--authrpc.jwtsecret=%d/jwtsecret"]
            ++ cliArgs
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            description = "Erigon Ethereum node (${erigonName})";
            wantedBy = ["multi-user.target"];
            after = ["network.target"];

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                User = serviceName;
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/erigon ${scriptArgs}";
                SystemCallFilter = ["@system-service" "~@privileged" "mincore"];
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["jwtsecret:${jwtSecret}"];
              })
            ];
          })
      )
      eachErigon;
  };
}
