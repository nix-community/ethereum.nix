{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs' nameValuePair;
  inherit (lib) concatStringsSep filterAttrs mapAttrsToList flatten elem optionals;
  inherit (lib.attrsets) zipAttrsWith;
  inherit (builtins) split last;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachBootnode = config.services.ethereum.geth-bootnode;
in {
  disabledModules = ["services/blockchain/ethereum/geth.nix"];

  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachBootnode != {}) {
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBootnode;
      perService =
        mapAttrsToList
        (_: cfg: let
          s = cfg.settings;
          # Parse port from addr like ":30301"
          port = lib.toInt (last (split ":" (s.addr or ":30301")));
        in {
          allowedUDPPorts = [port];
        })
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        gethName: cfg: let
          serviceName = "geth-bootnode-${gethName}";
          s = cfg.settings;
          nodekey = s.nodekey or null;

          # Keys to skip (handled separately)
          skipKeys = ["nodekey"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Bootnode uses single-dash format
          cliArgs = lib.cli.toGNUCommandLine {
            mkOptionName = k: "-${k}";
          } normalSettings;

          allArgs =
            cliArgs
            ++ optionals (nodekey != null) ["-nodekey" "%d/nodekey"]
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Go Ethereum Bootnode (${gethName})";

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/bootnode ${scriptArgs}";
              }
              (mkIf (nodekey != null) {
                LoadCredential = ["nodekey:${nodekey}"];
              })
            ];
          })
      )
      eachBootnode;
  };
}
