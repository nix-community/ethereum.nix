{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../../../lib/modules.nix lib;

  inherit (lib.attrsets) hasAttr zipAttrsWith;
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
    length
    ;
  inherit (builtins) isList;
  inherit (modulesLib) baseServiceConfig;

  eachValidator = config.services.ethereum.lighthouse-validator;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachValidator != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachValidator;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedTCPPorts =
              (optionals (s.http or false) [ (s."http-port" or 5062) ])
              ++ (optionals (s.metrics or false) [ (s."metrics-port" or 5064) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      name:
      let
        user = "lighthouse-${name}";
        serviceName = "lighthouse-validator-${name}";
      in
      cfg:
      let
        s = cfg.settings;
        datadir = s.datadir or "%S/${user}";

        # Beacon nodes: use provided value or look up from lighthouse-beacon service
        beaconNodes =
          if (s.beacon-nodes or null) != null && length (s.beacon-nodes or [ ]) != 0 then
            s.beacon-nodes
          else
            let
              beaconCfg = config.services.ethereum.lighthouse-beacon.${name};
              beaconSettings = beaconCfg.settings;
              beaconUrl = "http://${beaconSettings.http-address or "127.0.0.1"}:${
                toString (beaconSettings.http-port or 5052)
              }";
            in
            [ beaconUrl ];

        # Keys that need special handling
        skipKeys = [
          "datadir"
          "beacon-nodes"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        allArgs = [
          "--datadir"
          datadir
          "--beacon-nodes"
          (concatStringsSep "," beaconNodes)
        ]
        ++ cliArgs
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Lighthouse Validator Client (${name})";

          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = if cfg.user != null then cfg.user else user;
              StateDirectory = user;
              ExecStart = "${cfg.package}/bin/lighthouse validator ${scriptArgs}";
            }
          ];
        }
      )
    ) eachValidator;

    assertions = mapAttrsToList (name: cfg: {
      assertion =
        !cfg.enable
        || (cfg.settings.beacon-nodes or null) != null
        || (hasAttr name config.services.ethereum.lighthouse-beacon);
      message = ''
        Lighthouse Validator ${name} could not find a matching beacon.
        Either set `services.ethereum.lighthouse-beacon.${name}` or `services.ethereum.lighthouse-validator.${name}.settings.beacon-nodes`
      '';
    }) eachValidator;
  };
}
