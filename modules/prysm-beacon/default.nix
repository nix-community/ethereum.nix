{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix lib;

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

  eachBeacon = config.services.ethereum.prysm-beacon;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachBeacon != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBeacon;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [p2p-udp-port];
              allowedTCPPorts =
                [rpc-port p2p-tcp-port]
                ++ (optionals (!disable-monitoring) [monitoring-port])
                ++ (optionals (!disable-grpc-gateway) [grpc-gateway-port])
                ++ (optionals pprof [pprofport]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        beaconName: let
          serviceName = "prysm-beacon-${beaconName}";
        in
          cfg: let
            scriptArgs = let
              # generate args
              args = let
                opts = import ./args.nix lib;
              in
                mkArgs {
                  inherit opts;
                  inherit (cfg) args;
                };

              # filter out certain args which need to be treated differently
              specialArgs = ["--network" "--jwt-secret" "--datadir" "--user"];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
              filteredArgs = builtins.filter isNormalArg args;

              network =
                if cfg.args.network != null
                then "--${cfg.args.network}"
                else "";

              jwtSecret =
                if cfg.args.jwt-secret != null
                then "--jwt-secret %d/jwt-secret"
                else "";

              datadir =
                if cfg.args.datadir != null
                then "--datadir ${cfg.args.datadir}"
                else "--datadir %S/${serviceName}";
            in ''
              --accept-terms-of-use ${network} ${jwtSecret} \
              ${datadir} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Prysm Beacon Node (${beaconName})";

              environment = {
                GRPC_GATEWAY_HOST = cfg.args.grpc-gateway-host;
                GRPC_GATEWAY_PORT = builtins.toString cfg.args.grpc-gateway-port;
              };

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User =
                    if cfg.args.user != null
                    then cfg.args.user
                    else serviceName;
                  StateDirectory = serviceName;
                  ReadWritePaths = [ cfg.args.datadir ];
                  ExecStart = "${cfg.package}/bin/beacon-chain ${scriptArgs}";
                  MemoryDenyWriteExecute = "false"; # causes a library loading error
                }
                (mkIf (cfg.args.jwt-secret != null) {
                  LoadCredential = ["jwt-secret:${cfg.args.jwt-secret}"];
                })
              ];
            })
      )
      eachBeacon;
  };
}
