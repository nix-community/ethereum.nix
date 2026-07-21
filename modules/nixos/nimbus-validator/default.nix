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

  eachValidator = config.services.ethereum.nimbus-validator;

  # Convert lists to comma-separated strings for CLI
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

  # Gnosis networks use a different binary
  gnosisNetworks = [
    "gnosis"
    "chiado"
  ];
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
              (optionals (s.metrics or false) [ (s.metrics-port or 8008) ])
              ++ (optionals (s.keymanager or false) [ (s.keymanager-port or 5052) ]);
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      validatorName:
      let
        serviceName = "nimbus-validator-${validatorName}";
      in
      cfg:
      let
        s = cfg.settings;
        dataDir = s.data-dir or "%S/${serviceName}";
        network = s.network or validatorName;
        keymanagerTokenFile = s.keymanager-token-file or "api-token.txt";

        # Select appropriate binary based on network
        bin =
          if elem network gnosisNetworks then "nimbus_validator_client_gnosis" else "nimbus_validator_client";

        # Keys that need special handling
        skipKeys = [
          "data-dir"
          "keymanager-token-file"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        # Nimbus (confutils) only accepts --key=value, never "--key value": a
        # space-separated value is treated as a positional argument and rejected
        # ("nimbus_validator_client does not accept arguments"). Join with "=".
        cliArgs = lib.cli.toCommandLine (name: {
          option = "--${name}";
          sep = "=";
          explicitBool = false;
        }) (processSettings normalSettings);

        allArgs = [
          "--data-dir=${dataDir}"
        ]
        ++ cliArgs
        ++ (optionals (s.keymanager or false) [
          "--keymanager-token-file=${dataDir}/${keymanagerTokenFile}"
        ])
        ++ cfg.extraArgs;

        scriptArgs = concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Nimbus Validator Client (${validatorName})";

          serviceConfig = mkMerge [
            baseServiceConfig
            {
              # Nimbus requires JIT compilation
              MemoryDenyWriteExecute = false;

              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;

              # Create keymanager token file if it doesn't exist (only when the
              # keymanager API is enabled).
              ExecStartPre = lib.mkBefore (
                optionals (s.keymanager or false) [
                  ''
                    ${pkgs.coreutils-full}/bin/cp --no-preserve=all --update=none \
                    /proc/sys/kernel/random/uuid ${dataDir}/${keymanagerTokenFile}''
                ]
              );

              ExecStart = "${cfg.package}/bin/${bin} ${scriptArgs}";

              # Used by doppelganger detection to signal we should NOT restart.
              # https://nimbus.guide/doppelganger-detection.html
              RestartPreventExitStatus = 129;
            }
          ];
        }
      )
    ) eachValidator;
  };
}
