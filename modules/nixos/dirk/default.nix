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

  eachDirk = config.services.ethereum.dirk;

  format = pkgs.formats.yaml { };

  # Extract the port from a "host:port" or ":port" listen address string.
  portOf = addr: toInt (last (splitString ":" addr));
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachDirk != { }) {
    # open the gRPC server port for each service that requests it
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachDirk;
        perService = mapAttrsToList (
          _: cfg:
          let
            listenAddr = cfg.settings.server.listen-address or null;
          in
          {
            allowedTCPPorts = optionals (listenAddr != null) [ (portOf listenAddr) ];
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      name:
      let
        serviceName = "dirk-${name}";
      in
      cfg:
      let
        # Dirk reads <base-dir>/dirk.yaml via viper. Render the settings to
        # that file and hand Dirk a directory that contains it.
        configFile = format.generate "dirk.yaml" cfg.settings;
        baseDir = pkgs.linkFarm "dirk-${name}-base" [
          {
            name = "dirk.yaml";
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
          description = "Dirk remote keymanager (${name})";

          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;
              WorkingDirectory = "%S/${serviceName}";
              ExecStart = "${cfg.package}/bin/dirk ${scriptArgs}";
            }
          ];
        }
      )
    ) eachDirk;
  };
}
