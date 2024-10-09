{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (builtins)
    isBool
    isList
    toString
    ;
  inherit
    (lib)
    boolToString
    concatStringsSep
    filterAttrs
    findFirst
    flatten
    hasPrefix
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    optionals
    zipAttrsWith
    ;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) mkArgs baseServiceConfig;

  # capture config for all configured netherminds
  eachNethermind = config.services.ethereum.nethermind;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachNethermind != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNethermind;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [modules.Network.DiscoveryPort];
              allowedTCPPorts =
                [modules.Network.P2PPort modules.JsonRpc.EnginePort]
                ++ (optionals modules.JsonRpc.Enabled [modules.JsonRpc.Port modules.JsonRpc.WebSocketsPort])
                ++ (optionals modules.Metrics.Enabled && (modules.Metrics.ExposePort != null) [modules.Metrics.ExposePort]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services =
      mapAttrs' (
        nethermindName: let
          serviceName = "nethermind-${nethermindName}";
        in
          cfg: let
            scriptArgs = let
              # custom arg reducer for nethermind
              argReducer = value:
                if (isList value)
                then concatStringsSep "," value
                else if (isBool value)
                then boolToString value
                else toString value;

              # remove modules from arguments
              pathReducer = path: let
                arg = concatStringsSep "." (lib.lists.remove "modules" path);
              in "--${arg}";

              # custom arg formatter for nethermind
              argFormatter = {
                path,
                value,
                argReducer,
                pathReducer,
                ...
              }: let
                arg = pathReducer path;
              in "${arg} ${argReducer value}";

              jwtSecret =
                if cfg.args.modules.JsonRpc.JwtSecretFile != null
                then "--JsonRpc.JwtSecretFile %d/jwtsecret"
                else "";
              datadir =
                if cfg.args.datadir != null
                then "--datadir ${cfg.args.datadir}"
                else "--datadir %S/${serviceName}";

              # generate flags
              args = let
                opts = import ./args.nix lib;
              in
                mkArgs {
                  inherit pathReducer argReducer argFormatter opts;
                  inherit (cfg) args;
                };

              # filter out certain args which need to be treated differently
              specialArgs = ["--JsonRpc.JwtSecretFile"];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;

              filteredArgs = builtins.filter isNormalArg args;
            in ''
              ${datadir} \
              ${jwtSecret} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Nethermind Node (${nethermindName})";

              environment = {
                WEB3_HTTP_HOST = cfg.args.modules.JsonRpc.Host;
                WEB3_HTTP_PORT = builtins.toString cfg.args.modules.JsonRpc.Port;
              };

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                {
                  User = serviceName;
                  StateDirectory = serviceName;
                  MemoryDenyWriteExecute = false; # setting this option is incompatible with JIT
                  ExecStart = "${cfg.package}/bin/nethermind ${scriptArgs}";
                }
                baseServiceConfig
                (mkIf (cfg.args.modules.JsonRpc.JwtSecretFile != null) {
                  LoadCredential = ["jwtsecret:${cfg.args.modules.JsonRpc.JwtSecretFile}"];
                })
              ];
            })
      )
      eachNethermind;
  };
}
