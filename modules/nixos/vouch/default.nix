{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../../../lib/modules.nix lib;

  inherit (lib)
    concatStringsSep
    filterAttrs
    flatten
    last
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    optionals
    splitString
    toInt
    ;
  inherit (lib.attrsets) zipAttrsWith;
  inherit (modulesLib) baseServiceConfig;

  eachVouch = config.services.ethereum.vouch;

  format = pkgs.formats.yaml { };

  # Extract the port from a "host:port" or ":port" listen address string.
  portOf = addr: toInt (last (splitString ":" addr));
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachVouch != { }) {
    # open the metrics port for each service that requests it
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachVouch;
        perService = mapAttrsToList (
          _: cfg:
          let
            metricsAddr = cfg.settings.metrics.prometheus.listen-address or null;
          in
          {
            allowedTCPPorts = optionals (metricsAddr != null) [ (portOf metricsAddr) ];
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      name:
      let
        serviceName = "vouch-${name}";
      in
      cfg:
      let
        # Vouch reads <base-dir>/vouch.yaml via viper. Render the settings to
        # that file and hand Vouch a directory that contains it.
        configFile = format.generate "vouch.yaml" cfg.settings;
        baseDir = pkgs.linkFarm "vouch-${name}-base" [
          {
            name = "vouch.yaml";
            path = configFile;
          }
        ];

        allArgs = [
          "--base-dir=${baseDir}"
        ]
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Vouch validator client (${name})";

          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/vouch ${scriptArgs}";
            }
          ];
        }
      )
    ) eachVouch;
  };
}
