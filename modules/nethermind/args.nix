lib:
with lib; {
  baseDbPath = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = mdDoc "Configures the path of the Nethermind's database folder.";
  };

  config = mkOption {
    type = types.nullOr types.str;
    default = null;
    example = "mainnet";
    description = mdDoc "Determines the configuration file of the network on which Nethermind will be running.";
  };

  configsDirectory = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = mdDoc "Changes the source directory of your configuration files.";
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Data directory for Nethermind. Defaults to '%S/nethermind-\<name\>', which generally resolves to /var/lib/nethermind-\<name\>.";
  };

  log = mkOption {
    type = types.enum [
      "OFF"
      "TRACE"
      "DEBUG"
      "INFO"
      "WARN"
      "ERROR"
    ];
    default = "INFO";
    description = mdDoc "Changes the logging level.";
  };

  loggerConfigSource = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Changes the path of the NLog.config file.";
  };

  modules = {
    # https://docs.nethermind.io/nethermind/ethereum-client/configuration/network
    Network = {
      DiscoveryPort = mkOption {
        type = types.port;
        default = 30303;
        description = mdDoc "UDP port number for incoming discovery connections.";
      };

      P2PPort = mkOption {
        type = types.port;
        default = 30303;
        description = mdDoc "TPC/IP port number for incoming P2P connections.";
      };
    };

    # https://docs.nethermind.io/nethermind/ethereum-client/configuration/jsonrpc
    JsonRpc = {
      Enabled = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Defines whether the JSON RPC service is enabled on node startup.";
      };

      Port = mkOption {
        type = types.port;
        default = 8545;
        description = mdDoc "Port number for JSON RPC calls.";
      };

      WebSocketsPort = mkOption {
        type = types.port;
        default = 8545;
        description = mdDoc "Port number for JSON RPC web sockets calls.";
      };

      EngineHost = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = mdDoc "Host for JSON RPC calls.";
      };

      EnginePort = mkOption {
        type = types.port;
        default = 8551;
        description = mdDoc "Port for Execution Engine calls.";
      };

      JwtSecretFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = mdDoc "Path to file with hex encoded secret for jwt authentication.";
        example = "/var/run/geth/jwtsecret";
      };
    };

    # https://docs.nethermind.io/nethermind/ethereum-client/configuration/healthchecks
    HealthChecks = {
      Enabled = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "If 'true' then Health Check endpoints is enabled at /health.";
      };
    };

    # https://docs.nethermind.io/nethermind/ethereum-client/configuration/metrics
    Metrics = {
      Enabled = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "If 'true',the node publishes various metrics to Prometheus Pushgateway at given interval.";
      };

      ExposePort = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = mdDoc "If 'true' then Health Check endpoints is enabled at /health";
      };
    };
  };
}
