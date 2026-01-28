{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.lists) optional optionals findFirst;
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

  eachNode = config.services.ethereum.besu;
in
{
  inherit (import ./options.nix { inherit lib pkgs; }) options;

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
            ++ (optionals metrics.enable [ metrics.port ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # configure systemd to create the state directory with a subvolume
    systemd.tmpfiles.rules = map (name: "v /var/lib/private/besu-${name}") (
      builtins.attrNames (filterAttrs (_: v: v.subVolume) eachNode)
    );

    # create a service for each instance
    systemd.services = mapAttrs' (
      besuName:
      let
        serviceName = "besu-${besuName}";
      in
      cfg:
      let
        scriptArgs =
          let
            args = mkArgs {
              opts = import ./args.nix lib;
              pathReducer = dotPathReducer;
              inherit (cfg) args;
            };

            # filter out certain args which need to be treated differently
            specialArgs = [
              "--datadir"
              "--engine-api.enable"
              "--engine-api.jwtsecret"
              "--engine-api.port"
              "--http.enable"
              "--http.host"
              "--http.port"
              "--http.api"
              "--http.cors-domains"
              "--metrics.enable"
              "--metrics.host"
              "--metrics.port"
            ];

            isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
            filteredArgs =
              (builtins.filter isNormalArg args)
              ++ (optionals cfg.args.http.enable [
                "--engine-rpc-enabled=true"
                "--engine-rpc-port=${toString cfg.args.engine-api.port}"
              ])
              ++ (optionals cfg.args.http.enable (
                [
                  "--rpc-http-enabled=true"
                  "--rpc-http-host=${cfg.args.http.host}"
                  "--rpc-http-port=${toString cfg.args.http.port}"
                  "--rpc-http-cors-origins=${concatStringsSep "," cfg.args.http.cors-domains}"
                ]
                ++ (optional (cfg.args.http.api != [ ]) "--rpc-http-api=${concatStringsSep "," cfg.args.http.api}")
              ))
              ++ (optionals cfg.args.metrics.enable [
                "--metrics-enabled=true"
                "--metrics-host=${cfg.args.metrics.host}"
                "--metrics-port=${toString cfg.args.metrics.port}"
              ]);

            jwtSecret =
              if cfg.args.engine-api.jwtsecret != null then "--engine-jwt-secret=%d/jwtsecret" else "";

            data-dir = if cfg.args.data-dir != null then "${cfg.args.data-dir}" else "%S/${serviceName}";
          in
          ''
            --data-path=${data-dir} \
            ${jwtSecret} \
            ${concatStringsSep " \\\n" filteredArgs} \
            ${lib.escapeShellArgs cfg.extraArgs}
          '';
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          description = "Besu Execution Client (${besuName})";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/besu ${scriptArgs}";

              MemoryDenyWriteExecute = false;
            }
            (mkIf (cfg.args.engine-api.jwtsecret != null) {
              LoadCredential = [ "jwtsecret:${cfg.args.engine-api.jwtsecret}" ];
            })
          ];
        }
      )
    ) eachNode;
  };
}
