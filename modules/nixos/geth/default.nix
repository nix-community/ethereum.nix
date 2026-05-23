# Derived from https://github.com/NixOS/nixpkgs/blob/45b92369d6fafcf9e462789e98fbc735f23b5f64/nixos/modules/services/blockchain/ethereum/geth.nix
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

  eachGeth = config.services.ethereum.geth;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

  # Known network flags that become just --<network>
  networkFlags = [
    "mainnet"
    "goerli"
    "holesky"
    "sepolia"
    "hoodi"
  ];
in
{
  # Disable the service definition currently in nixpkgs
  disabledModules = [ "services/blockchain/ethereum/geth.nix" ];

  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachGeth != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachGeth;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedUDPPorts = [ (s.port or 30303) ];
            allowedTCPPorts = [
              (s.port or 30303)
            ]
            ++ [ (s."authrpc.port" or 8551) ]
            ++ (optionals (s.http or false) [ (s."http.port" or 8545) ])
            ++ (optionals (s.ws or false) [ (s."ws.port" or 8546) ])
            ++ (optionals (s.metrics or false) [ (s."metrics.port" or 6060) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      gethName:
      let
        serviceName = "geth-${gethName}";
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
        ]
        ++ networkFlags;
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        # Handle network flag (just --sepolia, not --sepolia=true)
        networkArg =
          let
            activeNetwork = lib.findFirst (n: s.${n} or false) null networkFlags;
          in
          optionals (activeNetwork != null) [ "--${activeNetwork}" ];

        allArgs = [
          "--datadir"
          datadir
          "--ipcdisable"
        ]
        ++ networkArg
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
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Go Ethereum node (${gethName})";

          environment = {
            WEB3_HTTP_HOST = s."http.addr" or "127.0.0.1";
            WEB3_HTTP_PORT = builtins.toString (s."http.port" or 8545);
          };

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/geth ${scriptArgs}";
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "jwtsecret:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachGeth;
  };
}
