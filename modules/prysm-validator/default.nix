{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib.attrsets) zipAttrsWith mapAttrsRecursive optionalAttrs;
  inherit (lib) mdDoc flatten nameValuePair filterAttrs mapAttrs mapAttrs' mapAttrsToList;
  inherit (lib) optionalString literalExpression mkEnableOption mkIf mkBefore mkOption mkMerge types concatStringsSep;

  modulesLib = import ../lib.nix {inherit lib pkgs;};
  inherit (modulesLib) mkArgs baseServiceConfig foldListToAttrs scripts;

  settingsFormat = pkgs.formats.yaml {};

  eachValidator = config.services.ethereum.prysm-validator;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

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
                ++ (optionals (rpc.enable) [rpc.port])
                ++ (optionals (!disable-monitoring) [monitoring-port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        validatorName: let
          serviceName = "prysm-validator-${validatorName}";
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
              specialArgs = ["--network" "--datadir" "--rpc-enable" "--graffiti" "--user"];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
              filteredArgs = builtins.filter isNormalArg args;

              rpc = if cfg.args.rpc.enable
                    then "--rpc"
                    else "";
              network =
                if cfg.args.network != null
                then "--${cfg.args.network}"
                else "";
              datadir =
                if cfg.args.datadir != null
                then "--datadir ${cfg.args.datadir}"
                else "" ;
              graffiti =  # Needs quoting
                if cfg.args.graffiti != null
                then "--graffiti \"${cfg.args.graffiti}\""
                else "";
            in ''
              --accept-terms-of-use ${network} \
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
                  DynamicUser = false;
                  User = cfg.args.user;
                  #StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/validator ${scriptArgs}";
                  MemoryDenyWriteExecute = "false"; # causes a library loading error
                }
              ];
            })
      )
      eachValidator;
  };
}
