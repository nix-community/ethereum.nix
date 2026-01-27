{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../lib.nix lib;

  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
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
    ;
  inherit (modulesLib) mkArgs baseServiceConfig;

  eachBeacon = config.services.ethereum.lighthouse-beacon;
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation

  config = mkIf (eachBeacon != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBeacon;
        perService = mapAttrsToList (
          _: cfg: with cfg.args; {
            allowedUDPPorts = [ discovery-port ] ++ (optionals (!disable-quic) [ quic-port ]);
            allowedTCPPorts =
              (optionals disable-quic [ quic-port ])
              ++ (optionals http.enable [ http.port ])
              ++ (optionals metrics.enable [ metrics.port ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    systemd.services = mapAttrs' (
      beaconName:
      let
        user = "lighthouse-${beaconName}";
        serviceName = "lighthouse-beacon-${beaconName}";
      in
      cfg:
      let
        scriptArgs =
          let
            args = mkArgs {
              opts = import ./args.nix {
                inherit lib;
                name = beaconName;
                config = cfg;
              };
              inherit (cfg) args;
            };

            # filter out certain args which need to be treated differently
            specialArgs = [
              "--execution-jwt"
              "--datadir"
              "--http-enable"
              "--http-address"
              "--http-port"
              "--metrics-enable"
              "--metrics-address"
              "--metrics-port"
              "--user"
            ];
            isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
            filteredArgs =
              (builtins.filter isNormalArg args)
              ++ (optionals cfg.args.http.enable [
                "--http"
                "--http-address=${cfg.args.http.address}"
                "--http-port=${toString cfg.args.http.port}"
              ])
              ++ (optionals cfg.args.metrics.enable [
                "--metrics"
                "--metrics-address=${cfg.args.metrics.address}"
                "--metrics-port=${toString cfg.args.metrics.port}"
              ]);

            jwtSecret = if cfg.args.execution-jwt != null then "--execution-jwt %d/execution-jwt" else "";

            datadir =
              if cfg.args.datadir != null then "--datadir ${cfg.args.datadir}" else "--datadir %S/${user}";
          in
          ''
            ${jwtSecret} \
            ${datadir} \
            ${concatStringsSep " \\\n" filteredArgs} \
            ${lib.escapeShellArgs cfg.extraArgs}
          '';
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Lighthouse Beacon Node (${beaconName})";

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = if cfg.args.user != null then cfg.args.user else user;
              StateDirectory = user;
              ExecStart = "${cfg.package}/bin/lighthouse beacon ${scriptArgs}";
            }
            (mkIf (cfg.args.execution-jwt != null) {
              LoadCredential = [ "execution-jwt:${cfg.args.execution-jwt}" ];
            })
          ];
        }
      )
    ) eachBeacon;
  };
}
