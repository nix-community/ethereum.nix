{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib)
    concatStringsSep
    filterAttrs
    flatten
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    zipAttrsWith
    ;

  modulesLib = import ../../../lib/modules.nix lib;
  inherit (modulesLib) baseServiceConfig mkArgs dotPathReducer;

  eachNode = config.services.ethereum.reth;
in
{
  # Disable the service definition currently in nixpkgs
  disabledModules = [ "services/blockchain/ethereum/reth.nix" ];

  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation

  config = mkIf (eachNode != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNode;
        perService = mapAttrsToList (
          _: cfg: with cfg.args; {
            allowedTCPPorts = [
              port
              authrpc.port
            ]
            ++ (optionals http.enable [ http.port ])
            ++ (optionals ws.enable [ ws.port ])
            ++ (optionals metrics.enable [ metrics.port ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # configure systemd to create the state directory with a subvolume
    systemd.tmpfiles.rules = map (name: "v /var/lib/private/reth-${name}") (
      builtins.attrNames (filterAttrs (_: v: v.subVolume) eachNode)
    );

    # create a service for each instance
    systemd.services = mapAttrs' (
      rethName:
      let
        serviceName = "reth-${rethName}";
      in
      cfg:
      let
        scriptArgs =
          let
            args = mkArgs {
              opts = import ./args.nix lib;
              pathReducer = dotPathReducer;
              args = builtins.removeAttrs cfg.args [ "ws" ];
            };

            wsArgs = mkArgs {
              opts = import ./args.nix lib;
              args = {
                ws = builtins.removeAttrs cfg.args.ws [ "enable" ];
              };
            };

            # filter out certain args which need to be treated differently
            specialArgs = [
              "--datadir"
              "--authrpc.jwtsecret"
              "--http.enable"
              "--metrics.enable"
              "--metrics.addr"
              "--metrics.port"
            ];

            isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
            filteredArgs =
              (builtins.filter isNormalArg args)
              ++ (optionals cfg.args.http.enable [ "--http" ])
              ++ (optionals cfg.args.ws.enable wsArgs)
              ++ (optionals cfg.args.metrics.enable [
                "--metrics"
                "${cfg.args.metrics.addr}:${toString cfg.args.metrics.port}"
              ]);

            jwtSecret = if cfg.args.authrpc.jwtsecret != null then "--authrpc.jwtsecret %d/jwtsecret" else "";

            datadir = if cfg.args.datadir != null then "${cfg.args.datadir}" else "%S/${serviceName}";
          in
          ''
            --log.file.directory ${datadir}/logs \
            --datadir ${datadir} \
            ${jwtSecret} \
            ${concatStringsSep " \\\n" filteredArgs} \
            ${lib.escapeShellArgs cfg.extraArgs}
          '';
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          description = "Reth Ethereum node (${rethName})";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/reth node ${scriptArgs}";

              # Reth needs this system call for some reason
              SystemCallFilter = [
                "@system-service"
                "~@privileged"
                "mincore"
              ];
            }
            (mkIf (cfg.args.authrpc.jwtsecret != null) {
              LoadCredential = [ "jwtsecret:${cfg.args.authrpc.jwtsecret}" ];
            })
          ];
        }
      )
    ) eachNode;
  };
}
