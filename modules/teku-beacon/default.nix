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
    (builtins)
    toString
    ;
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

  eachBeacon = config.services.ethereum.teku-beacon;
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
              allowedUDPPorts = [udp-port];
              allowedTCPPorts =
                [tcp-port]
                ++ (optionals rest-api.enable [rest-api.port])
                ++ (optionals metrics.enable [metrics.port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        beaconName: let
          user = "teku-beacon-${beaconName}";
          serviceName = "teku-beacon-${beaconName}";
        in
          cfg: let
            args = mkArgs {
              inherit (cfg) args;
              opts = import ./args.nix {
                inherit lib;
                name = beaconName;
                config = cfg;
              };
            };

            jwt-secret =
              if cfg.args.ee-jwt-secret-file != null
              then "--ee-jwt-secret-file=%d/jwt-secret"
              else "";
            data-path =
              if cfg.args.data-path != null
              then cfg.args.data-path
              else "%S/${serviceName}";
            data-path-arg = "--data-path=${data-path}";

            scriptArgs = let
              # filter out certain args which need to be treated differently
              specialArgs = [
                "--ee-jwt-secret-file"
                "--data-path"
                "--user" # Not a CLI Flag, only used in systemd service
                "--rest-api-enable"
                "--rest-api-address"
                "--rest-api-port"
                "--rest-api-cors-origins"
                "--metrics-enable"
                "--metrics-address"
                "--metrics-port"
                "--payload-builder-enable"
                "--payload-builder-url"
              ];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
              filteredArgs =
                (builtins.filter isNormalArg args)
                ++ (optionals cfg.args.rest-api.enable [
                  "--rest-api-enabled"
                  "--rest-api-interface=${cfg.args.rest-api.address}"
                  "--rest-api-port=${toString cfg.args.rest-api.port}"
                ])
                ++ (optionals cfg.args.metrics.enable [
                  "--metrics-enabled"
                  "--metrics-interface=${cfg.args.metrics.address}"
                  "--metrics-port=${toString cfg.args.metrics.port}"
                ]);
            in ''
              ${jwt-secret} \
              ${data-path-arg} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Teku Beacon Node (${beaconName})";

              serviceConfig = mkMerge [
                {
                  MemoryDenyWriteExecute = false;
                  User =
                    if cfg.args.user != null
                    then cfg.args.user
                    else user;
                  StateDirectory = user;
                  ExecStart = "${cfg.package}/bin/teku ${scriptArgs}";

                  # Teku needs this system call for some reason
                  SystemCallFilter = ["@system-service" "~@privileged" "mincore"];

                  # Used by doppelganger detection to signal we should NOT restart.
                  # https://docs.teku.consensys.net/how-to/prevent-slashing/detect-doppelgangers
                  RestartPreventExitStatus = 2;
                }
                baseServiceConfig
                (mkIf (cfg.args.ee-jwt-secret-file != null) {
                  LoadCredential = ["jwt-secret:${cfg.args.ee-jwt-secret-file}"];
                })
              ];
            })
      )
      eachBeacon;
  };
}
