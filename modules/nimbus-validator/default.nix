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
          cfg: let
            bin = let
              bins.gnosis = "nimbus_validator_client_gnosis";
              bins.chiado = "nimbus_validator_client_gnosis";
            in
              bins.${cfg.network} or "nimbus_validator_client";
          in
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
                  ExecStart = "${cfg.package}/bin/${bin} ${lib.escapeShellArgs cfg.extraArgs}";
                  MemoryDenyWriteExecute = "false";
                }
              ];
            })
      )
      eachNimbusValidator;
  };
}
