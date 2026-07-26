{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    literalExpression
    ;

  vouchOpts = {
    options = {
      enable = mkEnableOption "Vouch, an Ethereum multi-node validator client from Attestant";

      package = mkOption {
        type = types.package;
        default = pkgs.vouch;
        defaultText = literalExpression "pkgs.vouch";
        description = "Package to use for the Vouch binary.";
      };

      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "User to run the systemd service. When null, a dynamic user is used.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open the Prometheus metrics port in the firewall. The port is parsed
          from `settings.metrics.prometheus.listen-address`.
        '';
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = (pkgs.formats.yaml { }).type;
        };
        default = { };
        description = ''
          Vouch configuration. Rendered verbatim to a `vouch.yaml` file that
          Vouch reads through `--base-dir`. Use the nested keys documented at
          <https://github.com/attestantio/vouch/blob/master/docs/configuration.md>.

          Secrets (wallet passphrases, client certificates) should be provided
          as majordomo references (e.g. `"file:///run/credentials/..."`) rather
          than inline values, since the generated file is world-readable in the
          Nix store.
        '';
        example = literalExpression ''
          {
            log-level = "info";
            beacon-node-addresses = [ "localhost:5051" ];
            metrics.prometheus.listen-address = "127.0.0.1:8081";
            accountmanager.dirk = {
              endpoints = [ "signer:8881" ];
              accounts = [ "Validators" ];
              client-cert = "file:///etc/vouch/client.crt";
              client-key = "file:///etc/vouch/client.key";
              ca-cert = "file:///etc/vouch/ca.crt";
            };
            blockrelay = {
              fallback-fee-recipient = "0x0000000000000000000000000000000000000001";
              fallback-gas-limit = 30000000;
            };
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional command-line arguments passed to Vouch.";
      };
    };
  };
in
{
  options.services.ethereum.vouch = mkOption {
    type = types.attrsOf (types.submodule vouchOpts);
    default = { };
    description = "Specification of one or more Vouch validator instances.";
  };
}
