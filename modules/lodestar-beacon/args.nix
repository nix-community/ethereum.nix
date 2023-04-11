lib:
with lib; {
  dataDir = mkOption {
      type = types.nullOr types.str;
      default = null
      description = mkDoc "Lodestar root data directory";
  };

  network = mkOption {
      type = types.str;
      default = "mainnet";
      description = mkDoc "Name of the Ethereum Consensus chain network to join";
  };

  paramsFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Network configuration file";
  };

  terminal-total-difficulty-override = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Terminal PoW block TTD override";
  };

  terminal-block-hash-override = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Terminal PoW block hash override";
  };

  terminal-block-hash-epoch-override = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Terminal PoW block hash override activation epoch";
  };

  checkpointSyncUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Server url hosting Beacon Node APIs to fetch weak subjectivity state. Fetch latest finalized by default, else set --wssCheckpoint";
  };

  checkpointState = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Set a checkpoint state to start syncing from";
  };

  wssCheckpoint = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Start beacon node off a state at the provided weak subjectivity checkpoint, to be supplied in : format. For example, 0x1234:100 will sync and start off from the weakSubjectivity state at checkpoint of epoch 100 with block root 0x1234.";
  };

  logLevel = mkOption {
      type = types.str;
      default = "info";
      description = mkDoc "Logging verbosity level for emittings logs to terminal";
  };

  logFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Path to output all logs to a persistent log file, use 'none' to disable";
  };

  logFileLevel = mkOption {
      type = types.str;
      default = "debug";
      description = mkDoc "Logging verbosity level for emittings logs to file";
  };

  logFileDailyRotate = mkOption {
      type = types.int;
      default = 5;
      description = mkDoc "Daily rotate log files, set to an integer to limit the file count, set to 0(zero) to disable rotation";
  };

  rest = mkOption {
      type = types.bool;
      default = true;
      description = mkDoc "Enable/disable HTTP API";
  };

  rest.namespace = mkOption {
      type = types.listOf types.str;
      default = ["beacon" "config" "events" "node" "validator" "lightclient"];
      description = mkDoc "Pick namespaces to expose for HTTP API. Set to '*' to enable all namespaces";
  };

  rest.cors = mkOption {
      type = types.listOf types.str;
      default = ["*"];
      description = mkDoc "Configures the Access-Control-Allow-Origin CORS header for HTTP API";
  };

  rest.address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mkDoc "Set host for HTTP API";
  };

  rest.port = mkOption {
      type = types.port;
      default = 9596;
      description = mkDoc "Set port for HTTP API";
  };

  suggestedFeeRecipient = mkOption {
      type = types.str;
      default = "0x0000000000000000000000000000000000000000";
      description = mkDoc "Specify fee recipient default for collecting the EL block fees and rewards (a hex string representing 20 bytes address: ^0x[a-fA-F0-9]{40}$) in case validator fails to update for a validator index before calling produceBlock.";
  };

  emitPayloadAttributes = mkOption {
      type = types.bool;
      default = false;
      description = mkDoc "Flag to SSE emit execution payloadAttributes before every slot";
  };

  eth1 = mkOption {
      type = types.bool;
      default = true;
      description = mkDoc "Whether to follow the eth1 chain";
  };

  eth1.providerUrls = mkOption {
      type = types.listOf types.str
      default = ["http://localhost:8545"];
      description = mkDoc "Urls to Eth1 node with enabled rpc. If not explicity provided and execution endpoint provided via execution.urls, it will use execution.urls. Otherwise will try connecting on the specified default(s)";
  };

  execution.urls = mkOption {
    type = types.nullOr (types.listOf types.str);
    default = null;
    description = mkDoc "Urls to execution client engine API";
  };

  execution.timeout = mkOption {
      type = types.int;
      default = 5000;
      description = mkDoc "Timeout in milliseconds for execution engine API HTTP client";
  };

  execution.retryAttempts = mkOption {
      type = types.int;
      default = 1;
      description = mkDoc "Number of retry attempts when calling execution engine API";
  };

  execution.retryDelay = mkOption {
      type = types.int;
      default = 0;
      description = mkDoc "Delay time in milliseconds between retries when retrying calls to the execution engine API";
  };

  jwt-secret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "File path to a shared hex-encoded jwt secret which will be used to generate and bundle HS256 encoded jwt tokens for authentication with the EL client's rpc server hosting engine apis. Secret to be exactly same as the one used by the corresponding EL client.";
  };

  builder = mkOption {
      type = types.bool;
      default = false;
      description = mkDoc "Enable builder interface";
  };

  builder.urls = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mkDoc "Urls hosting the builder API";
  };

  builder.timeout = mkOption {
      type = types.int;
      default = 5000;
      description = mkDoc "Timeout in milliseconds for builder API HTTP client";
  };

  builder.faultInspectionWindow = mkOption {
      type = types.int;
      default = 3;
      description = mkDoc "Window to inspect missed slots for enabling/disabling builder circuit breaker";
  };

  builder.allowedFaults = mkOption {
      type = types.int;
      default = 2;
      description = mkDoc "Number of missed slots allowed in the faultInspectionWindow for builder circuit";
  };

  metrics = mkOption {
      type = types.bool;
      default = false;
      description = mkDoc "Enable the Prometheus metrics HTTP server";
  };

  metrics.port = mkOption {
      type = types.port;
      default = 8008;
      description = mkDoc "Listen TCP port for the Prometheus metrics HTTP server";
  };

  metrics.address = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Listen address for the Prometheus metrics HTTP server";
  };

  monitoring.endpoint = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Enables monitoring service for sending clients stats to the specified endpoint of a remote service (e.g. beaconcha.in). It is required that metrics are also enabled by supplying the --metrics flag.";
  };

  monitoring.interval = mkOption {
      type = types.int;
      default = 60000;
      description = mkDoc "Interval in milliseconds between sending client stats to the remote service";
  };

  discv5 = mkOption {
      type = types.bool;
      default = true;
      description = mkDoc "Enable discv5";
  };

  listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = mkDoc "The address to listen for p2p UDP and TCP connections";
  };

  port = mkOption {
      type = types.port;
      default = 9000;
      description = mkDoc "The TCP/UDP port to listen on. The UDP port can be modified by the --discovery-port flag.";
  };

  discoveryPort = mkOption {
      type = types.port;
      default = port;
      description = mkDoc "The UDP port that discovery will listen on. Defaults to port.";
  
  bootnodes = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mkDoc "Bootnodes for discv5 discovery";
  };

  targetPeers = mkOption {
      type = types.int;
      default = 50;
      description = mkDoc "The target connected peers. Above this number peers will be disconnected";
  };

  subscribeAllSubnets = mkOption {
      type = types.bool;
      default = false;
      description = mkDoc "Subscribe to all subnets regardless of validator count";
  };

  mdns = mkOption {
      type = types.bool;
      default = false;
      description = mkDoc "Enable mdns local peer discovery";
  };

  terminal-total-difficulty-override = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Terminal PoW block TTD override";
  };

  terminal-block-hash-override = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Terminal PoW block hash override";
  };

  terminal-block-hash-epoch-override = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Terminal PoW block hash override activation epoch";
  };

  enr.ip = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Override ENR IP entry";
  };

  enr.tcp = mkOption {
      type = types.int;
      default = 0;
      description = mkDoc "Override ENR TCP entry";
  };

  enr.udp = mkOption {
      type = types.int;
      default = 0;
      description = mkDoc "Override ENR UDP entry";
  };

  enr.ip6 = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mkDoc "Override ENR IPv6 entry";
  };

  enr.tcp6 = mkOption {
      type = types.int;
      default = 0;
      description = mkDoc "Override ENR (IPv6-specific) TCP entry";
  };

  enr.udp6 = mkOption {
      type = types.int;
      default = 0;
      description = mkDoc "Override ENR (IPv6-specific) UDP entry";
  };
}