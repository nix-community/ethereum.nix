{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs' nameValuePair;
  inherit (lib) concatStringsSep filterAttrs elem mapAttrs;
  inherit (lib.trivial) boolToString;
  inherit (builtins) isList isBool;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachNimbusValidator = config.services.ethereum.nimbus-validator;

  # Convert lists to comma-separated, bools to strings
  processSettings = mapAttrs (_: v:
    if isList v then concatStringsSep "," v
    else if isBool v then boolToString v
    else v);
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachNimbusValidator != {}) {
    systemd.services =
      mapAttrs'
      (
        nimbusValidatorName: cfg: let
          serviceName = "nimbus-validator-${nimbusValidatorName}";
          s = cfg.settings;
          network = s.network or "mainnet";
          dataDir = s.data-dir or "%S/${serviceName}";

          # Keys to skip (handled separately)
          skipKeys = ["network" "data-dir" "user"];
          normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

          # Nimbus uses = separator
          cliArgs = lib.cli.toCommandLine (name: {
            option = "--${name}";
            sep = "=";
            explicitBool = false;
          }) (processSettings normalSettings);

          allArgs =
            ["--data-dir=${dataDir}"]
            ++ cliArgs
            ++ cfg.extraArgs;

          scriptArgs = concatStringsSep " \\\n  " allArgs;

          # Binary selection for gnosis/chiado
          bin = {
            gnosis = "nimbus_validator_client_gnosis";
            chiado = "nimbus_validator_client_gnosis";
          }.${network} or "nimbus_validator_client";
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Nimbus Validator Client (${nimbusValidatorName})";

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                User = s.user or serviceName;
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/${bin} ${scriptArgs}";
                MemoryDenyWriteExecute = "false";

                # Used by doppelganger detection to signal we should NOT restart.
                # https://nimbus.guide/doppelganger-detection.html
                RestartPreventExitStatus = 129;
              }
            ];
          })
      )
      eachNimbusValidator;
  };
}
