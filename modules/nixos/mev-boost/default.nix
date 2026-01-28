{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../../../lib/modules.nix lib;

  inherit (lib)
    nameValuePair
    mapAttrs'
    mkIf
    mkMerge
    concatStringsSep
    filterAttrs
    optionals
    elem
    mapAttrs
    ;
  inherit (builtins) isList;
  inherit (modulesLib) baseServiceConfig;

  eachMevBoost = config.services.ethereum.mev-boost;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

  # Known network flags that become just --<network>
  networkFlags = [
    "mainnet"
    "holesky"
    "sepolia"
    "zhejiang"
    "hoodi"
  ];
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachMevBoost != { }) {
    systemd.services = mapAttrs' (
      mevBoostName:
      let
        serviceName = "mev-boost-${mevBoostName}";
      in
      cfg:
      let
        s = cfg.settings;

        # Keys that need special handling
        skipKeys = [
          "relays"
          "relay-monitors"
        ]
        ++ networkFlags;
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Use lib.cli.toGNUCommandLine for RFC 42 settings
        cliArgs = lib.cli.toGNUCommandLine { } (processSettings normalSettings);

        # Handle network flag (just --holesky, not --holesky=true)
        networkArg =
          let
            activeNetwork = lib.findFirst (n: s.${n} or false) null networkFlags;
          in
          optionals (activeNetwork != null) [ "--${activeNetwork}" ];

        # Handle relays (required, comma-separated)
        relaysArg = optionals (s.relays or [ ] != [ ]) [
          "--relays"
          (concatStringsSep "," s.relays)
        ];

        # Handle relay-monitors (optional, comma-separated)
        relayMonitorsArg = optionals (s.relay-monitors or null != null) [
          "--relay-monitors"
          (concatStringsSep "," s.relay-monitors)
        ];

        allArgs = networkArg ++ cliArgs ++ relaysArg ++ relayMonitorsArg ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "MEV-Boost (${mevBoostName})";

          # create service config by merging with the base config
          serviceConfig = mkMerge [
            baseServiceConfig
            {
              User = serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/mev-boost ${scriptArgs}";
            }
          ];
        }
      )
    ) eachMevBoost;
  };
}
