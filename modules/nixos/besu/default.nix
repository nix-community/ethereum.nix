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
    concatStringsSep
    filterAttrs
    flatten
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    optionals
    elem
    ;
  inherit (builtins) isList attrNames;
  inherit (modulesLib) baseServiceConfig;

  eachBesu = config.services.ethereum.besu;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachBesu != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBesu;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedUDPPorts = [ (s.p2p-port or 30303) ];
            allowedTCPPorts = [
              (s.p2p-port or 30303)
            ]
            ++ [ (s.engine-rpc-port or 8551) ]
            ++ (optionals (s.rpc-http-enabled or false) [ (s.rpc-http-port or 8545) ])
            ++ (optionals (s.rpc-ws-enabled or false) [ (s.rpc-ws-port or 8546) ])
            ++ (optionals (s.metrics-enabled or false) [ (s.metrics-port or 6060) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # configure systemd to create the state directory with a subvolume
    systemd.tmpfiles.rules = map (name: "v /var/lib/private/besu-${name}") (
      attrNames (filterAttrs (_: v: v.subVolume) eachBesu)
    );

    # create a service for each instance
    systemd.services = mapAttrs' (
      besuName:
      let
        serviceName = "besu-${besuName}";
      in
      cfg:
      let
        s = cfg.settings;
        dataPath = s.data-path or "%S/${serviceName}";
        jwtSecret = s.engine-jwt-secret or null;

        # Keys that need special handling
        skipKeys = [
          "data-path"
          "engine-jwt-secret"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        allArgs = [
          "--data-path"
          dataPath
        ]
        ++ cliArgs
        ++ (optionals (jwtSecret != null) [
          "--engine-jwt-secret"
          "%d/jwtsecret"
        ])
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Besu Ethereum Execution Client (${besuName})";

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/besu ${scriptArgs}";

              # Besu requires JIT compilation
              MemoryDenyWriteExecute = false;
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "jwtsecret:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachBesu;
  };
}
