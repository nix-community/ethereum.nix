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

  dirkOpts = {
    options = {
      enable = mkEnableOption "Dirk, a distributed remote keymanager from Attestant";

      package = mkOption {
        type = types.package;
        default = pkgs.dirk;
        defaultText = literalExpression "pkgs.dirk";
        description = "Package to use for the Dirk binary.";
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
          Open the gRPC server port in the firewall. The port is parsed from
          `settings.server.listen-address`.
        '';
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = (pkgs.formats.yaml { }).type;
        };
        default = { };
        description = ''
          Dirk configuration. Rendered verbatim to a `dirk.yaml` file that Dirk
          reads through `--base-dir`. Use the nested keys documented at
          <https://github.com/attestantio/dirk/blob/master/docs/configuration.md>.

          `storage-path` (slashing protection) and any filesystem `stores`
          (wallets) must point at writable, persistent locations. The service
          provides a state directory at `/var/lib/dirk-<name>` (also the working
          directory), so relative paths are resolved there.

          Secrets (passphrases, private keys) should be provided as majordomo
          references (e.g. `"file:///run/credentials/..."`) rather than inline
          values, since the generated file is world-readable in the Nix store.
        '';
        example = literalExpression ''
          {
            server = {
              id = 12345678;
              name = "dirk.example.com";
              listen-address = "0.0.0.0:13141";
            };
            certificates = {
              server-cert = "file:///var/lib/dirk-main/security/server.crt";
              server-key = "file:///var/lib/dirk-main/security/server.key";
              ca-cert = "file:///var/lib/dirk-main/security/ca.crt";
            };
            storage-path = "/var/lib/dirk-main/protection";
            stores = [
              {
                name = "Local";
                type = "filesystem";
                location = "/var/lib/dirk-main/wallets";
              }
            ];
            unlocker.account-passphrases = [ "file:///run/credentials/dirk-main/passphrase" ];
            peers."12345678" = "dirk.example.com:13141";
            permissions."client1".Local = "All";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional command-line arguments passed to Dirk.";
      };
    };
  };
in
{
  options.services.ethereum.dirk = mkOption {
    type = types.attrsOf (types.submodule dirkOpts);
    default = { };
    description = "Specification of one or more Dirk keymanager instances.";
  };
}
