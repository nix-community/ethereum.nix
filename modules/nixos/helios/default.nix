{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.lists) optionals;
  inherit (lib)
    filterAttrs
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    ;

  modulesLib = import ../../../lib/modules.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachNode = config.services.ethereum.helios;
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachNode != { }) {
    assertions = mapAttrsToList (name: cfg: {
      assertion = !cfg.startWhenNeeded || cfg.args.rpc.enable;
      message = "services.ethereum.helios.${name}: startWhenNeeded requires rpc.enable to be true.";
    }) eachNode;

    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNode;
        perService = mapAttrsToList (
          _: cfg: with cfg.args; {
            allowedTCPPorts = optionals rpc.enable [ rpc.port ];
          }
        ) openFirewall;
      in
      builtins.zipAttrsWith (_name: builtins.concatLists) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      heliosName:
      let
        serviceName = "helios-${heliosName}";
      in
      cfg:
      let
        # Determine command based on network
        isOpStack = cfg.args.network != "ethereum";
        subcommand = if isOpStack then "opstack" else "ethereum";

        # Build argument list
        execArgs = [
          subcommand
        ]
        ++ (optionals isOpStack [
          "--network"
          cfg.args.network
        ])
        ++ [
          "--execution-rpc"
          cfg.args.executionRpc
          "--rpc-port"
          (toString cfg.args.rpc.port)
          "--rpc-bind-ip"
          cfg.args.rpc.addr
        ]
        ++ (optionals (cfg.args.consensusRpc != null) [
          "--consensus-rpc"
          cfg.args.consensusRpc
        ])
        ++ (optionals (cfg.args.checkpoint != null) [
          "--checkpoint"
          cfg.args.checkpoint
        ])
        ++ (optionals (cfg.args.checkpointFallback != null) [
          "--fallback"
          cfg.args.checkpointFallback
        ])
        ++ (optionals (cfg.args.datadir != null) [
          "--data-dir"
          cfg.args.datadir
        ])
        ++ (optionals cfg.args.loadExternalFallback [
          "--load-external-fallback"
        ])
        ++ cfg.extraArgs;

        datadir = if cfg.args.datadir != null then cfg.args.datadir else "%S/${serviceName}";
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          description = "Helios ${cfg.args.network} light client (${heliosName})";
          wantedBy = optionals (!cfg.startWhenNeeded) [ "multi-user.target" ];
          after = [ "network.target" ];

          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/helios ${lib.escapeShellArgs execArgs} --data-dir ${datadir}";
            }
            (mkIf (cfg.startWhenNeeded && cfg.args.rpc.enable) {
              Sockets = [ "${serviceName}.socket" ];
            })
          ];
        }
      )
    ) eachNode;

    # create socket units for startWhenNeeded instances
    systemd.sockets = mapAttrs' (
      heliosName: cfg:
      let
        serviceName = "helios-${heliosName}";
      in
      nameValuePair serviceName (
        mkIf (cfg.enable && cfg.startWhenNeeded && cfg.args.rpc.enable) {
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "${cfg.args.rpc.addr}:${toString cfg.args.rpc.port}";
          };
        }
      )
    ) eachNode;
  };
}
