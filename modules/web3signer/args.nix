lib:
with lib; {
  http-listen-port = mkOption {
    type = types.port;
    description = "Port to listen for signing request.";
  };
  mode = mkOption {
    type = types.str;
  };
  eth2 = {
    network = mkOption {
      type = types.str;
      description = "Network";
    };
    slashing-protection-enabled = mkOption {
      type = types.bool;
      default = true;
      description = "Disable slashing-protection by default";
    };
    slashing-protection-pruning-enabled = mkOption {
      type = types.bool;
    };
    slashing-protection-db-url = mkOption {
      type = types.str;
    };
    slashing-protection-db-username = mkOption {
      type = types.str;
    };
    slashing-protection-db-password = mkOption {
      type = types.str;
    };
    keystores-path = mkOption {
      type = types.str;
      description = "Path to JSON keystore produced by deposit_cli";
    };
    keystores-passwords-path = mkOption {
      type = types.str;
      description = "Path to password files corresponding to the keystores.";
    };
  };
}
