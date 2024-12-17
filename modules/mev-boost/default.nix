{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix lib;

  inherit (lib.lists) findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib) nameValuePair mapAttrs';
  inherit (lib) mkIf mkMerge concatStringsSep;
  inherit (modulesLib) mkArgs baseServiceConfig;

  eachMevBoost = config.services.ethereum.mev-boost;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachMevBoost != {}) {
    systemd.services =
      mapAttrs'
      (
        mevBoostName: let
          serviceName = "mev-boost-${mevBoostName}";
        in
          cfg: let
            scriptArgs = let
              # generate args
              args = let
                opts = import ./args.nix lib;
              in
                mkArgs {
                  inherit opts;
                  inherit (cfg) args;
                };

              # filter out certain args which need to be treated differently
              specialArgs = [
                "--network"
                "--holesky"
                "--mainnet"
                "--relay-monitor"
                "--relay-monitors"
                "--relay"
                "--relays"
                "--sepolia"
                "--zhejiang"
              ];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;
              filteredArgs = builtins.filter isNormalArg args;

              network =
                if cfg.args.network != null
                then "--${cfg.args.network}"
                else "";

              relays = "--relays " + (concatStringsSep "," cfg.args.relays);
              relayMonitors =
                if cfg.args.relay-monitors != null
                then "--relay-monitors" + (concatStringsSep "," cfg.args.relay-monitors)
                else "";
            in ''
              ${network} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${relays} \
              ${relayMonitors} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
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
            })
      )
      eachMevBoost;
  };
}
