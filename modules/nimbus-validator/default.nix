{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mapAttrs'
    mkIf
    mkMerge
    nameValuePair
    ;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachNimbusValidator = config.services.ethereum.nimbus-validator;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachNimbusValidator != {}) {
    # create a service for each instance
    systemd.services =
      mapAttrs' (
        nimbusValidatorName: let
          serviceName = "nimbus-validator-${nimbusValidatorName}";
        in
          cfg:
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Nimbus Validator Client (${nimbusValidatorName})";

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User =
                    if cfg.user != null
                    then cfg.user
                    else serviceName;
                  StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/nimbus_validator_client ${lib.escapeShellArgs cfg.extraArgs}";
                  MemoryDenyWriteExecute = "false";
                }
              ];
            })
      )
      eachNimbusValidator;
  };
}
