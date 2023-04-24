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
  inherit (modulesLib) mkArgs baseServiceConfig;

  # capture config for all configured geths
  eachBootnode = config.services.ethereum.geth-bootnode;
in {
  # Disable the service definition currently in nixpkgs
  disabledModules = ["services/blockchain/ethereum/geth.nix"];

  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = with lib;
    mkIf (eachBootnode != {}) {
      # configure the firewall for each service
      networking.firewall = let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBootnode;
        perService =
          mapAttrsToList
          (
            _: cfg:
              with cfg.args; let
                # todo this can probably be improved with regex
                port = toInt (last (builtins.split ":" addr));
              in {
                allowedUDPPorts = [port];
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
            serviceName = "geth-bootnode-${gethName}";
          in
            cfg: let
              scriptArgs = let
                # of course flags for this process are `-foo` instead of `--foo`...
                pathReducer = path: let
                  arg = concatStringsSep "-" path;
                in "-${arg}";

                # generate flags
                args = let
                  opts = import ./args.nix lib;
                in
                  mkArgs {
                    inherit pathReducer opts;
                    inherit (cfg) args;
                  };

                # filter out certain args which need to be treated differently
                specialArgs = ["-nodekey"];
                isNormalArg = name: (findFirst (arg: arg == name) null specialArgs) == null;

                filteredArgs = builtins.filter isNormalArg args;
              in ''
                ${concatStringsSep " \\\n" filteredArgs} \
                ${lib.escapeShellArgs cfg.extraArgs}
              '';
            in
              nameValuePair serviceName (mkIf cfg.enable {
                after = ["network.target"];
                wantedBy = ["multi-user.target"];
                description = "Go Ethereum Bootnode (${gethName})";

                # create service config by merging with the base config
                serviceConfig = mkMerge [
                  baseServiceConfig
                  {
                    User = serviceName;
                    StateDirectory = serviceName;
                    ExecStart = "${cfg.package}/bin/bootnode ${scriptArgs}";
                  }
                  (mkIf (cfg.args.nodekey != null) {
                    LoadCredential = ["nodekey:${cfg.args.nodekey}"];
                  })
                ];
              })
        )
        eachBootnode;
    };
}
