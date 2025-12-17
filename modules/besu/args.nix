lib:
with lib; {
  data-dir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Data directory for Besu. Defaults to '%S/besu-\<name\>', which generally resolves to /var/lib/besu-\<name\>.";
  };

  p2p-port = mkOption {
    type = types.port;
    default = 30303;
    description = "Network listening port.";
  };

  network = mkOption {
    type = types.enum [
      "mainnet"
      "hoodi"
      "sepolia"
      "ephemery"
      "linea_mainnet"
      "linea_sepolia"
      "lukso"
      "dev"
    ];
    default = "mainnet";
    description = "Name of the network to join. If null the network is mainnet.";
  };

  logging = mkOption {
    type = types.enum ["OFF" "FATAL" "ERROR" "WARN" "INFO" "DEBUG" "TRACE" "ALL"];
    default = "INFO";
    description = "Log level";
  };

  http = {
    enable = mkEnableOption "Enable HTTP-RPC server";

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "HTTP-RPC server listening interface.";
    };

    port = mkOption {
      type = types.port;
      default = 8545;
      description = "HTTP-RPC server listening port.";
    };

    cors-domains = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = ["none"];
      description = "List of domains from which to accept cross origin requests.";
      example = ["*"];
    };

    api = mkOption {
      type = types.listOf types.str;
      description = "APIs offered over the HTTP-RPC interface.";
      example = ["net" "eth"];
      default = [];
    };
  };

  engine-api = {
    enable = mkEnableOption "Enable the engine API";

    port = mkOption {
      type = types.port;
      default = 8551;
      description = "HTTP-RPC server listening port for the Engine API";
    };

    jwtsecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to the token that ensures safe connection between CL and EL.";
      example = "/var/run/besu/jwtsecret";
    };
  };

  metrics = {
    enable = mkEnableOption "Enable Prometheus metrics collection and reporting.";

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Metrics HTTP server listening bind address";
    };

    port = mkOption {
      type = types.port;
      default = 6060;
      description = "Metrics HTTP server listening port";
    };
  };
}
