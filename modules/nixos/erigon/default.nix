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
  inherit (builtins) isList;
  inherit (modulesLib) baseServiceConfig;

  eachErigon = config.services.ethereum.erigon;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);
in
{
  # Disable the service definition currently in nixpkgs
  disabledModules = [ "services/blockchain/ethereum/erigon.nix" ];

  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation

  config = mkIf (eachErigon != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachErigon;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedUDPPorts = [
              (s.port or 30303)
              (s."torrent.port" or 42069)
            ];
            allowedTCPPorts = [
              (s.port or 30303)
              (s."authrpc.port" or 8551)
              (s."torrent.port" or 42069)
            ]
            ++ (optionals (s.http or false) [ (s."http.port" or 8545) ])
            ++ (optionals (s.ws or false) [ (s."ws.port" or 8546) ])
            ++ (optionals (s.metrics or false) [ (s."metrics.port" or 6060) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # configure systemd to create the state directory with a subvolume
    systemd.tmpfiles.rules = map (name: "v /var/lib/private/erigon-${name}") (
      builtins.attrNames (filterAttrs (_: v: v.subVolume) eachErigon)
    );

    # create a service for each instance
    systemd.services = mapAttrs' (
      erigonName:
      let
        serviceName = "erigon-${erigonName}";
      in
      cfg:
      let
        s = cfg.settings;
        datadir = s.datadir or "%S/${serviceName}";
        jwtSecret = s."authrpc.jwtsecret" or null;

        # Keys that need special handling
        skipKeys = [
          "datadir"
          "authrpc.jwtsecret"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        allArgs = [
          "--datadir"
          datadir
        ]
        ++ cliArgs
        ++ (optionals (jwtSecret != null) [
          "--authrpc.jwtsecret"
          "%d/jwtsecret"
        ])
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          description = "Erigon Ethereum node (${erigonName})";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              SupplementaryGroups = cfg.service.supplementaryGroups;
              ExecStart = "${cfg.package}/bin/erigon ${scriptArgs}";

              # Erigon needs this system call for some reason
              SystemCallFilter = [
                "@system-service"
                "~@privileged"
                "mincore"
              ];
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "jwtsecret:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachErigon;
  };
}
