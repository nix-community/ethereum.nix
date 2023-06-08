lib:
with lib; {
  network = mkOption {
    type = types.nullOr (types.enum ["goerli" "prater" "ropsten" "sepolia"]);
    default = null;
    description = mdDoc "The network to connect to. Mainnet (null) is the default ethereum network.";
  };

  disable-monitoring = mkOption {
    type = types.bool;
    default = false;
    description = mdDoc "Disable monitoring service.";
  };

  monitoring-host = mkOption {
    type = types.str;
    default = "127.0.0.1";
    description = mdDoc "Host used to listen and respond with metrics for prometheus.";
  };

  monitoring-port = mkOption {
    type = types.port;
    default = 8081;
    description = mdDoc "Port used to listen and respond with metrics for prometheus.";
  };

  grpc-gateway-host = mkOption {
    type = types.str;
    default = "127.0.0.1";
    description = mdDoc "The host on which the gateway server runs on.";
  };

  grpc-gateway-port = mkOption {
    type = types.port;
    default = 7500;
    description = mdDoc "The port on which the gateway server runs.";
  };

  rpc = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Enable the Enables the RPC server for the validator.";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "Host on which the RPC server should listen.";
    };

    port = mkOption {
      type = types.port;
      default = 7000;
      description = mdDoc "RPC port exposed by a validator client.";
    };
  };

  wallet-dir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Path to a wallet directory on-disk for Prysm validator accounts";
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Data directory for the databases. Defaults to the default datadir for Prysm Beacon";
  };

  wallet-password-file = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Path to a plain-text, .txt file containing your wallet password";
  };

  suggested-fee-recipient = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc ''      Sets ALL validators' mapping to a suggested eth\
                              address to receive gas fees when proposing a block. note\
                              that this is only a suggestion when integrating with a Builder API,\
                              which may choose to specify a different fee recipient as payment\
                              for the blocks it builds.'';
  };

  graffiti = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "String to include in proposed blocks";
  };

  user = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "User to run the systemd service.";
  };
}
