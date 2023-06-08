lib:
with lib; {
  network = mkOption {
    type = types.nullOr (types.enum ["goerli" "prater" "ropsten" "sepolia"]);
    default = null;
    description = mdDoc "The network to connect to. Mainnet (null) is the default ethereum network.";
  };

  jwt-secret = mkOption {
    type = types.str;
    default = null;
    description = mdDoc "Path to a file containing a hex-encoded string representing a 32 byte secret used for authentication with an execution node via HTTP";
    example = "/var/run/prysm/jwtsecret";
  };

  checkpoint-sync-url = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "URL of a synced beacon node to trust in obtaining checkpoint sync data. As an additional safety measure, it is strongly recommended to only use this option in conjunction with --weak-subjectivity-checkpoint flag";
    example = "https://goerli.checkpoint-sync.ethpandaops.io";
  };

  genesis-beacon-api-url = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "URL of a synced beacon node to trust for obtaining genesis state. As an additional safety measure, it is strongly recommended to only use this option in conjunction with --weak-subjectivity-checkpoint flag";
    example = "https://goerli.checkpoint-sync.ethpandaops.io";
  };

  p2p-udp-port = mkOption {
    type = types.port;
    default = 12000;
    description = mdDoc "The port used by discv5.";
  };

  p2p-tcp-port = mkOption {
    type = types.port;
    default = 13000;
    description = mdDoc "The port used by libp2p.";
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
    default = 8080;
    description = mdDoc "Port used to listen and respond with metrics for prometheus.";
  };

  disable-grpc-gateway = mkOption {
    type = types.bool;
    default = false;
    description = mdDoc "Disable the gRPC gateway for JSON-HTTP requests ";
  };

  grpc-gateway-host = mkOption {
    type = types.str;
    default = "127.0.0.1";
    description = mdDoc "The host on which the gateway server runs on.";
  };

  grpc-gateway-port = mkOption {
    type = types.port;
    default = 3500;
    description = mdDoc "The port on which the gateway server runs.";
  };

  rpc-host = mkOption {
    type = types.str;
    default = "127.0.0.1";
    description = mdDoc "Host on which the RPC server should listen.";
  };

  rpc-port = mkOption {
    type = types.port;
    default = 4000;
    description = mdDoc "RPC port exposed by a beacon node.";
  };

  pprof = mkOption {
    type = types.bool;
    default = false;
    description = mdDoc "Enable the pprof HTTP server.";
  };

  pprofaddr = mkOption {
    type = types.str;
    default = "127.0.0.1";
    description = mdDoc "pprof HTTP server listening interface.";
  };

  pprofport = mkOption {
    type = types.port;
    default = 6060;
    description = mdDoc "pprof HTTP server listening port.";
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Data directory for the databases.";
  };

  user = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "User to run the systemd service.";
  };
}
