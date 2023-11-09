{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (builtins)
    toString
    ;
  inherit
    (lib)
    filterAttrs
    flatten
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    zipAttrsWith
    ;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachNimbus = config.services.ethereum.nimbus;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachNimbus != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNimbus;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [port];
              allowedTCPPorts = [port];
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services =
      mapAttrs' (
        nimbusName: let
          serviceName = "nimbus-${nimbusName}";
        in
          cfg:
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Nimbus Node (${nimbusName})";

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User =
                    if cfg.user != null
                    then cfg.user
                    else serviceName;
                  StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/nimbus_beacon_node --tcp-port=${builtins.toString cfg.args.port} --network=${cfg.args.network} --jwt-secret=${cfg.args.jwtsecret} --udp-port=${builtins.toString cfg.args.port} ${lib.escapeShellArgs cfg.extraArgs}";
                  MemoryDenyWriteExecute = "false";
                }
              ];
            })
      )
      eachNimbus;
  };
}
