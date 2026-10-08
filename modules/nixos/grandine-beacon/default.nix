{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../../../lib/modules.nix lib;

  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib)
    filterAttrs
    flatten
    mapAttrs'
    mapAttrsToList
    mkForce
    mkIf
    mkMerge
    nameValuePair
    optionals
    elem
    ;
  inherit (modulesLib) baseServiceConfig;

  eachBeacon = config.services.ethereum.grandine-beacon;

  settingsFormat = pkgs.formats.yaml { };
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
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedUDPPorts = [ (s.discovery-port or 9000) ];
            allowedTCPPorts = [
              (s.libp2p-port or 9000)
            ]
            ++ (optionals (!(s.disable-http-api or false)) [ (s.http-port or 5052) ])
            ++ (optionals (s.metrics or false) [ (s.metrics-port or 5054) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      beaconName:
      let
        serviceName = "grandine-beacon-${beaconName}";
      in
      cfg:
      let
        s = cfg.settings;
        dataDir = s.data-dir or "%S/${serviceName}";
        jwtSecret = s.jwt-secret or null;

        # Keys that need systemd specifier expansion (%S, %d), so they can't
        # be baked into the static args file and are passed as CLI args instead.
        skipKeys = [
          "data-dir"
          "jwt-secret"
        ];
        # Null-valued settings (e.g. an unset checkpoint-sync-url) must be
        # dropped entirely, not written as a literal `null` -- grandine
        # rejects that as an unsupported value instead of treating it as
        # unset.
        normalSettings = filterAttrs (k: v: !elem k skipKeys && v != null) s;

        argsFile = settingsFormat.generate "${serviceName}-args.yaml" normalSettings;

        allArgs = [
          "--args-file"
          (toString argsFile)
          "--data-dir"
          dataDir
        ]
        ++ (optionals (jwtSecret != null) [
          "--jwt-secret"
          "%d/jwt-secret"
        ])
        ++ cfg.extraArgs;

        scriptArgs = lib.concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Grandine Beacon Node (${beaconName})";

          serviceConfig = mkMerge [
            baseServiceConfig
            (mkIf (cfg.user != null) {
              # A statically-managed user is incompatible with DynamicUser.
              DynamicUser = mkForce false;
            })
            {
              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/grandine ${scriptArgs}";
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "jwt-secret:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachBeacon;
  };
}
