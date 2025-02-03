{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix lib;

  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib.attrsets) hasAttr zipAttrsWith;
  inherit
    (lib)
    concatStringsSep
    filterAttrs
    flatten
    length
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    ;
  inherit (modulesLib) mkArgs baseServiceConfig;

  eachValidator = config.services.ethereum.lighthouse-validator;
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
                (optionals http.enable [http.port])
                ++ (optionals metrics.enable [metrics.port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    systemd.services =
      mapAttrs'
      (
        name: let
          user = "lighthouse-${name}";
          serviceName = "lighthouse-validator-${name}";
        in
          cfg: let
            scriptArgs = let
              # generate args
              args = let
                opts = import ./args.nix {inherit name lib;};
              in
                mkArgs {
                  inherit opts;
                  inherit (cfg) args;
                };

              # filter out certain args which need to be treated differently
              specialArgs = [
                "--datadir"
                "--http-enable"
                "--http-address"
                "--http-port"
                "--metrics-enable"
                "--metrics-address"
                "--metrics-port"
                "--beacon-nodes"
                "--user"
              ];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
              filteredArgs =
                (builtins.filter isNormalArg args)
                ++ (optionals cfg.args.http.enable ["--http" "--http-address=${cfg.args.http.address}" "--http-port=${toString cfg.args.http.port}"])
                ++ (optionals cfg.args.metrics.enable ["--metrics" "--metrics-address=${cfg.args.metrics.address}" "--metrics-port=${toString cfg.args.metrics.port}"]);

              datadir =
                if cfg.args.datadir != null
                then "--datadir ${cfg.args.datadir}"
                else "--datadir %S/${user}";

              beaconNodes =
                if (cfg.args.beacon-nodes != null) && (length cfg.args.beacon-nodes != 0)
                then "--beacon-nodes ${concatStringsSep "," cfg.args.beacon-nodes}"
                else let
                  beaconCfg = config.services.ethereum.lighthouse-beacon.${name};
                  beaconUrl = "http://${beaconCfg.args.http.address}:${toString beaconCfg.args.http.port}";
                in "--beacon-nodes ${beaconUrl}";
            in ''
              ${datadir} \
              ${beaconNodes} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Lighthouse Validator Client (${name})";

              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User =
                    if cfg.args.user != null
                    then cfg.args.user
                    else user;
                  StateDirectory = user;
                  ExecStart = "${cfg.package}/bin/lighthouse validator ${scriptArgs}";
                }
              ];
            })
      )
      eachValidator;

    assertions =
      mapAttrsToList
      (
        name: cfg: {
          assertion =
            !cfg.enable || (cfg.args.beacon-nodes != null) || (hasAttr name config.services.ethereum.lighthouse-beacon);
          message = ''
            Lighthouse Validator ${name} could not find a matching beacon.
            Either set `services.ethereum.lighthouse-beacon.${name}` or `services.ethereum.lighthouse-validator.${name}.args.beacon-nodes`
          '';
        }
      )
      eachValidator;
  };
}
