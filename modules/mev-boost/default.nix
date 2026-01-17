{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs' nameValuePair concatStringsSep mapAttrs;
  inherit (builtins) isList;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachMevBoost = config.services.ethereum.mev-boost;

  # Convert lists to comma-separated strings
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachMevBoost != {}) {
    systemd.services =
      mapAttrs'
      (
        mevBoostName: cfg: let
          serviceName = "mev-boost-${mevBoostName}";

          # Everything via lib.cli
          cliArgs = lib.cli.toCommandLine (name: {
            option = "-${name}";
            sep = null;
            explicitBool = false;
          }) (processSettings cfg.settings);

          allArgs = cliArgs ++ cfg.extraArgs;
          scriptArgs = concatStringsSep " \\\n  " allArgs;
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "MEV-Boost (${mevBoostName})";

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/mev-boost ${scriptArgs}";
              }
            ];
          })
      )
      eachMevBoost;
  };
}
