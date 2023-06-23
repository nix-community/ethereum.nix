{
  config,
  lib,
  name,
  pkgs,
  ...
}:
with lib; let
  # taken from process-compose flake, might not be necessary depending on how custom impl evolves
  removeNullAndEmptyAttrs = attrs: let
    f = filterAttrsRecursive (_key: value: value != null && value != {});
    # filterAttrsRecursive doesn't delete the *resulting* empty attrs, so we must
    # evaluate it again and to get rid of it.
  in
    pipe attrs [f f];

  # taken from process-compose flake, might not be necessary depending on how custom impl evolves
  toYAMLFile = attrs:
    pkgs.runCommand "${name}.yaml" {buildInputs = [pkgs.yq-go];} ''
      yq -oy -P '.' ${pkgs.writeTextFile {
        name = "process-compose-${name}.json";
        text = builtins.toJSON attrs;
      }} > $out
    '';

  # The list of supported devnets
  devnetSchema = {
    anvil = mkOption {
      type = types.submodule ./anvil.nix;
      description = ''
        Settings related to Anvil development network.
      '';
      default = {};
    };

    offchainlabs = mkOption {
      type = types.submodule ./offchainlabs.nix;
      description = ''
        Settings related to OffChainLabs development network with Geth + Prysm.
      '';
      default = {};
    };
  };
in {
  # Interface
  options = {
    package = mkPackageOption pkgs "process-compose" {};

    debug = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to dump extra information at start.
      '';
    };

    datadir = mkOption {
      type = types.either types.path types.str;
      description = "Path where to store information";
    };

    devnets = devnetSchema;

    outputs.build.processCompose = {
      wrapper = mkOption {
        type = types.package;
        description = ''
          The final package that will run the `preInitCommand`, the `process-compose` command and the `preTeardownCommand` for this configuration.
        '';
      };

      preInitCommand = mkOption {
        type = with types; nullOr oneOf [str shellPackage];
        internal = true;
      };

      preTeardownCommand = mkOption {
        type = with types; nullOr oneOf [str shellPackage];
        internal = true;
      };

      configYaml = mkOption {
        type = with types; attrsOf raw;
        internal = true;
      };

      upCommandArgs = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  # Implementation
  config = {
    assertions = [
      {
        assertion = [] == []; # TODO: Only allow one devnet per configurations
        message = ''
          Only one devnet network "${concatStringsSep ", " (attrNames devnetSchema)}" can be enabled per configuration in devnet.${name}.
        '';
      }
    ];

    outputs.build.processCompose = {
      configYaml = toYAMLFile (removeNullAndEmptyAttrs config.devnets.offchainlabs);

      wrapper = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [config.package];
        text = ''
          ${
            if config.debug
            then "cat ${config.outputs.processCompose.configYaml}"
            else ""
          }

          # preInitCommand

          process-compose up \
            --config ${config.outputs.processCompose.configYaml} \
            ${config.outputs.processCompose.upCommandArgs} \
            "$@"

          # TODO: add preTeardownCommand
        '';
      };
    };
  };
}
