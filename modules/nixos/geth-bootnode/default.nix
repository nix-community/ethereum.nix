# Derived from https://github.com/NixOS/nixpkgs/blob/45b92369d6fafcf9e462789e98fbc735f23b5f64/nixos/modules/services/blockchain/ethereum/geth.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../../../lib/modules.nix lib;

  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib)
    concatStringsSep
    filterAttrs
    flatten
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    optionals
    elem
    last
    toInt
    ;
  inherit (modulesLib) baseServiceConfig;

  eachBootnode = config.services.ethereum.geth-bootnode;
in
{
  # Disable the service definition currently in nixpkgs
  disabledModules = [ "services/blockchain/ethereum/geth.nix" ];

  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachBootnode != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBootnode;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
            # Extract port from addr string (e.g., ":30301" -> 30301)
            addr = s.addr or ":30301";
            port = toInt (last (builtins.split ":" addr));
          in
          {
            allowedUDPPorts = [ port ];
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      bootnodeName:
      let
        serviceName = "geth-bootnode-${bootnodeName}";
      in
      cfg:
      let
        s = cfg.settings;
        nodekey = s.nodekey or null;

        # Keys that need special handling (nodekey uses LoadCredential)
        skipKeys = [ "nodekey" ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine with single-dash prefix for bootnode
        cliArgs = lib.cli.toGNUCommandLine {
          mkOptionName = name: "-${name}";
        } normalSettings;

        allArgs =
          cliArgs
          ++ (optionals (nodekey != null) [
            "-nodekey"
            "%d/nodekey"
          ])
          ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Go Ethereum Bootnode (${bootnodeName})";

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/bootnode ${scriptArgs}";
            }
            (mkIf (nodekey != null) {
              LoadCredential = [ "nodekey:${nodekey}" ];
            })
          ];
        }
      )
    ) eachBootnode;
  };
}
