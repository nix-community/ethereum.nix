/*
* Derived from https://github.com/NixOS/nixpkgs/blob/45b92369d6fafcf9e462789e98fbc735f23b5f64/nixos/modules/services/blockchain/ethereum/geth.nix
*/
{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix {inherit lib pkgs;};

  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib.attrsets) zipAttrsWith;
  inherit
    (lib)
    concatStringsSep
    filterAttrs
    flatten
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    ;
  inherit (modulesLib) mkArgs baseServiceConfig;

  # capture config for all configured geths
  eachGeth = config.services.ethereum.geth;
in {
  # Disable the service definition currently in nixpkgs
  disabledModules = ["services/blockchain/ethereum/geth.nix"];

  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachGeth != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachGeth;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [port];
              allowedTCPPorts =
                [port authrpc.port]
                ++ (optionals http.enable [http.port])
                ++ (optionals ws.enable [ws.port])
                ++ (optionals metrics.enable [metrics.port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services =
      mapAttrs'
      (
        gethName: let
          serviceName = "geth-${gethName}";
        in
          cfg: let
            scriptArgs = let
              # replace enable flags like --http.enable with just --http
              pathReducer = path: let
                arg = concatStringsSep "." (lib.lists.remove "enable" path);
              in "--${arg}";

              # generate flags
              args = let
                opts = import ./args.nix lib;
              in
                mkArgs {
                  inherit pathReducer opts;
                  inherit (cfg) args;
                };

              # filter out certain args which need to be treated differently
              specialArgs = ["--network" "--authrpc.jwtsecret"];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;

              filteredArgs = builtins.filter isNormalArg args;

              network =
                if cfg.args.network != null
                then "--${cfg.args.network}"
                else "";

              jwtSecret =
                if cfg.args.authrpc.jwtsecret != null
                then "--authrpc.jwtsecret %d/jwtsecret"
                else "";
            in ''
              --ipcdisable ${network} ${jwtSecret} \
              --datadir %S/${serviceName} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Go Ethereum node (${gethName})";

              environment = {
                WEB3_HTTP_HOST = cfg.args.http.addr;
                WEB3_HTTP_PORT = builtins.toString cfg.args.http.port;
              };

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User = serviceName;
                  StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/geth ${scriptArgs}";
                }
                (mkIf (cfg.args.authrpc.jwtsecret != null) {
                  LoadCredential = ["jwtsecret:${cfg.args.authrpc.jwtsecret}"];
                })
              ];
            })
      )
      eachGeth;
  };
}
