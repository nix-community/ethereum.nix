{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../../../lib/modules.nix lib;

  inherit (lib.lists) optionals;
  inherit (lib)
    concatStringsSep
    filterAttrs
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mkForce
    mkIf
    mkMerge
    nameValuePair
    elem
    ;
  inherit (builtins) isList;
  inherit (modulesLib) baseServiceConfig;

  eachNode = config.services.ethereum.helios;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachNode != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNode;
        perService = mapAttrsToList (_: cfg: {
          allowedTCPPorts = [ (cfg.settings.rpc-port or 8545) ];
        }) openFirewall;
      in
      builtins.zipAttrsWith (_name: builtins.concatLists) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      heliosName:
      let
        serviceName = "helios-${heliosName}";
      in
      cfg:
      let
        s = cfg.settings;
        network = s.network or "ethereum";
        dataDir = s.data-dir or "%S/${serviceName}";

        # Helios uses subcommands: `ethereum` for mainnet, `opstack` for OP Stack
        # chains (which additionally take `--network <chain>`).
        isOpStack = network != "ethereum";
        subcommand = if isOpStack then "opstack" else "ethereum";

        # Keys handled explicitly below rather than as generic flags.
        skipKeys = [
          "network"
          "data-dir"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Helios is a clap CLI and accepts space-separated values, so use the
        # default separator.
        cliArgs = lib.cli.toCommandLine (name: {
          option = "--${name}";
          sep = null;
          explicitBool = false;
        }) (processSettings normalSettings);

        allArgs = [
          subcommand
        ]
        ++ (optionals isOpStack [
          "--network"
          network
        ])
        ++ cliArgs
        ++ [
          "--data-dir"
          dataDir
        ]
        ++ cfg.extraArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          description = "Helios ${network} light client (${heliosName})";
          wantedBy = optionals (!cfg.startWhenNeeded) [ "multi-user.target" ];
          after = [ "network.target" ];

          serviceConfig = mkMerge [
            baseServiceConfig
            (mkIf (cfg.user != null) {
              # A statically-managed user is incompatible with DynamicUser.
              DynamicUser = mkForce false;
            })
            {
              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/helios ${lib.escapeShellArgs allArgs}";
            }
            (mkIf cfg.startWhenNeeded {
              Sockets = [ "${serviceName}.socket" ];
            })
          ];
        }
      )
    ) eachNode;

    # create socket units for startWhenNeeded instances
    systemd.sockets = mapAttrs' (
      heliosName: cfg:
      let
        serviceName = "helios-${heliosName}";
      in
      nameValuePair serviceName (
        mkIf (cfg.enable && cfg.startWhenNeeded) {
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "${cfg.settings.rpc-bind-ip or "127.0.0.1"}:${
              toString (cfg.settings.rpc-port or 8545)
            }";
          };
        }
      )
    ) eachNode;
  };
}
