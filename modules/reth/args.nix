lib:
with lib; {
  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Data directory for Reth. Defaults to '%S/reth-\<name\>', which generally resolves to /var/lib/reth-\<name\>.";
  };

  port = mkOption {
    type = types.port;
    default = 30303;
    description = mdDoc "Network listening port.";
  };

  chain = mkOption {
    type = types.enum [
      "mainnet"
      "sepolia"
      "holesky"
      "dev"
    ];
    default = "mainnet";
    description = mdDoc "Name of the network to join. If null the network is mainnet.";
  };

  full = mkOption {
    type = types.bool;
    default = false;
    description = mdDoc "Run full node. Only the most recent [`MINIMUM_PRUNING_DISTANCE`] block states are stored. This flag takes priority over pruning configuration in reth.toml";
  };

  http = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc "Enable HTTP-RPC server";
    };

    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "HTTP-RPC server listening interface.";
    };

    port = mkOption {
      type = types.port;
      default = 8545;
      description = mdDoc "HTTP-RPC server listening port.";
    };

    corsdomain = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mdDoc "List of domains from which to accept cross origin requests.";
      example = ["*"];
    };

    api = mkOption {
      type = types.nullOr (types.listOf types.str);
      description = mdDoc "API's offered over the HTTP-RPC interface.";
      example = ["net" "eth"];
    };
  };

  ws = {
    enable = mkEnableOption (mdDoc "Reth WebSocket API");
    addr = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "WS server listening interface.";
      example = "127.0.0.1";
    };

    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = mdDoc "WS server listening port.";
      example = 8545;
    };

    origins = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mdDoc "List of origins from which to accept `WebSocket` requests";
    };

    api = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mdDoc "API's offered over the WS interface.";
      example = ["net" "eth"];
    };
  };

  authrpc = {
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "HTTP-RPC server listening interface for the Engine API.";
    };

    port = mkOption {
      type = types.port;
      default = 8551;
      description = mdDoc "HTTP-RPC server listening port for the Engine API";
    };

    jwtsecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Path to the token that ensures safe connection between CL and EL.";
      example = "/var/run/reth/jwtsecret";
    };
  };

  metrics = {
    enable = mkEnableOption (mdDoc "Enable Prometheus metrics collection and reporting.");

    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "Enable stand-alone metrics HTTP server listening interface.";
    };

    port = mkOption {
      type = types.port;
      default = 6060;
      description = mdDoc "Metrics HTTP server listening port";
    };
  };

  log = let
    mkFormatOpt = channel:
      mkOption {
        type = types.nullOr (types.enum ["terminal" "log-fmt" "json"]);
        default = null;
        description = mdDoc "The format to use for logs written to ${channel}.";
        example = "log-fmt";
      };
    mkFilterOpt = channel:
      mkOption {
        type = types.nullOr types.str;
        default = null;
        description = mdDoc "The filter to use for logs written to ${channel}.";
        example = "info";
      };
  in {
    stdout = {
      format = mkFormatOpt "stdout";
      filter = mkFilterOpt "stdout";
    };
    file = {
      format = mkFormatOpt "the log file";
      filter = mkFilterOpt "the log file";
      directory = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = mdDoc "The path to put log files in";
        example = "/var/log/reth";
      };
    };
    journald = {
      filter = mkFilterOpt "journald";
    };
  };
}
