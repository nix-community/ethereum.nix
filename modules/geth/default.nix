{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs' nameValuePair;
  inherit (lib) concatStringsSep filterAttrs mapAttrsToList flatten optionals elem mapAttrs;
  inherit (lib.attrsets) zipAttrsWith;
  inherit (builtins) isList;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachGeth = config.services.ethereum.geth;

  # Convert lists to comma-separated strings
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);
in {
  disabledModules = ["services/blockchain/ethereum/geth.nix"];

  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachGeth != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachGeth;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
        in {
          allowedUDPPorts = [(s.port or 30303)];
          allowedTCPPorts =
            [(s.port or 30303) (s."authrpc.port" or 8551)]
            ++ optionals (s.http or false) [(s."http.port" or 8545)]
            ++ optionals (s.ws or false) [(s."ws.port" or 8546)]
            ++ optionals (s.metrics or false) [(s."metrics.port" or 6060)];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        gethName: cfg: let
          serviceName = "geth-${gethName}";
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
          }) (processSettings normalSettings);

          allArgs =
            ["--datadir" datadir "--ipcdisable"]
            ++ cliArgs
            ++ optionals (jwtSecret != null) ["--authrpc.jwtsecret" "%d/jwtsecret"]
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Go Ethereum node (${gethName})";

            environment = {
              WEB3_HTTP_HOST = s."http.addr" or "127.0.0.1";
              WEB3_HTTP_PORT = toString (s."http.port" or 8545);
            };

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                User = serviceName;
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/geth ${scriptArgs}";
              }
              (mkIf (jwtSecret != null) {
                LoadCredential = ["jwtsecret:${jwtSecret}"];
              })
            ];
          })
      )
      eachGeth;
  };
}
