{
  config,
  lib,
  ethereum-nix,
  ...
}: let
  modulesLib = import ../lib.nix lib;

  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib) flatten nameValuePair filterAttrs mapAttrs' mapAttrsToList;
  inherit (lib) mkIf mkMerge concatStringsSep;
  inherit (modulesLib) mkArgs baseServiceConfig;

  eachValidator = config.services.ethereum.prysm-validator;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib ethereum-nix;}) options;

  ###### implementation

  config = mkIf (eachValidator != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachValidator;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedTCPPorts =
                [grpc-gateway-port]
                ++ (optionals rpc.enable [rpc.port])
                ++ (optionals (!disable-monitoring) [monitoring-port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        validatorName: let
          serviceName = "prysm-validator-${validatorName}";
          beaconServiceName = "prysm-beacon-${validatorName}";
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
              specialArgs = [
                "--datadir"
                "--graffiti"
                "--network"
                "--rpc-enable"
                "--user"
              ];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
              filteredArgs = builtins.filter isNormalArg args;

              network =
                if cfg.args.network != null
                then "--${cfg.args.network}"
                else "";

              datadir =
                if cfg.args.datadir != null
                then "--datadir ${cfg.args.datadir}"
                else "--datadir %S/${beaconServiceName}";
            in ''
              --accept-terms-of-use \
              ${network} \
              ${datadir} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Prysm Validator Node (${validatorName})";

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
                    else beaconServiceName;
                  StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/validator ${scriptArgs}";
                  MemoryDenyWriteExecute = "false"; # causes a library loading error
                }
              ];
            })
      )
      eachValidator;
  };
}
