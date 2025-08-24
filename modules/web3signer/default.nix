{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (builtins)
    isBool
    toString
    ;
  inherit
    (lib)
    boolToString
    mapAttrs'
    mkIf
    mkMerge
    nameValuePair
    ;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) mkArgs baseServiceConfig;

  eachWeb3signer = config.services.ethereum.web3signer;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachWeb3signer != {}) {
    # configure the firewall for each service
    networking.firewall = let
       openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachWeb3signer;
       mkAllowedPort = _: cfg: {
         allowedTCPPorts = [cfg.args.http-listen-port];
       };
       perService =
         mapAttrsToList mkAllowedPort openFirewall;
     in
       zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services =
      mapAttrs' (
        web3signerName: let
          serviceName = "web3signer-${web3signerName}";
        in
          cfg: let
            scriptArgs = let
              # generate flags
              argReducer = value:
                if (isBool value)
                then boolToString value
                else toString value;
              argFormatter = {
                path,
                value,
                argReducer,
                pathReducer,
                ...
              }: "${pathReducer path}=${argReducer value}";
              args = let
                opts = import ./args.nix lib;
              in
                mkArgs {
                  inherit argReducer argFormatter;
                  opts = opts.eth2;
                  args = cfg.args.eth2;
                };
            in ''
              --http-listen-port=${builtins.toString cfg.args.http-listen-port} ${cfg.args.mode} ${lib.escapeShellArgs args}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Web3signer Node (${web3signerName})";

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User =
                    if cfg.user != null
                    then cfg.user
                    else serviceName;
                  StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/web3signer ${scriptArgs}";
                  # Required for JVM
                  MemoryDenyWriteExecute = "false";
                }
              ];
            })
      )
      eachWeb3signer;
  };
}
