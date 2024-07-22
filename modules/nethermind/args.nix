lib:
with lib; {
  baseDbPath = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = "Configures the path of the Nethermind's database folder.";
  };

  config = mkOption {
    type = types.nullOr types.str;
    default = null;
    example = "mainnet";
    description = "Determines the configuration file of the network on which Nethermind will be running.";
  };

  configsDirectory = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = "Changes the source directory of your configuration files.";
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Data directory for Nethermind. Defaults to '%S/nethermind-\<name\>', which generally resolves to /var/lib/nethermind-\<name\>.";
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
    description = "Changes the logging level.";
  };

  loggerConfigSource = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Changes the path of the NLog.config file.";
  };

  modules = {
    # https://docs.nethermind.io/nethermind/ethereum-client/configuration/network
    Network = {
      DiscoveryPort = mkOption {
        type = types.port;
        default = 30303;
        description = "UDP port number for incoming discovery connections.";
      };

      P2PPort = mkOption {
        type = types.port;
        default = 30303;
        description = "TPC/IP port number for incoming P2P connections.";
      };
    };

    # https://docs.nethermind.io/nethermind/ethereum-client/configuration/jsonrpc
    JsonRpc = {
      Enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Defines whether the JSON RPC service is enabled on node startup.";
      };

      Port = mkOption {
        type = types.port;
        default = 8545;
        description = "Port number for JSON RPC calls.";
      };

      WebSocketsPort = mkOption {
        type = types.port;
        default = 8545;
        description = "Port number for JSON RPC web sockets calls.";
      };

      EngineHost = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Host for JSON RPC calls.";
      };

      EnginePort = mkOption {
        type = types.port;
        default = 8551;
        description = "Port for Execution Engine calls.";
      };

      JwtSecretFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to file with hex encoded secret for jwt authentication.";
        example = "/var/run/geth/jwtsecret";
      };
    };

    # https://docs.nethermind.io/nethermind/ethereum-client/configuration/healthchecks
    HealthChecks = {
      Enabled = mkOption {
        type = types.bool;
        default = true;
        description = "If 'true' then Health Check endpoints is enabled at /health.";
      };
    };

    # https://docs.nethermind.io/nethermind/ethereum-client/configuration/metrics
    Metrics = {
      Enabled = mkOption {
        type = types.bool;
        default = true;
        description = "If 'true',the node publishes various metrics to Prometheus Pushgateway at given interval.";
      };

      ExposePort = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "If 'true' then Health Check endpoints is enabled at /health";
      };
    };
  };
}
