{
  lib,
  name,
  config,
  ...
}:
with lib; {
  network = mkOption {
    type = types.nullOr (types.enum ["mainnet" "prater" "goerli" "gnosis" "chiado" "sepolia" "holesky"]);
    default = name;
    defaultText = "name";
    description = "The network to connect to. Mainnet is the default ethereum network.";
  };

  execution-endpoint = mkOption {
    type = types.str;
    default = "http://127.0.0.1:8551";
    description = ''
      Listen address for the execution layer.
    '';
  };

  execution-jwt = mkOption {
    type = types.str;
    default = null;
    description = ''
      Path to a file containing a hex-encoded string representing a 32 byte secret
      used for authentication with an execution node via HTTP
    '';
    example = "/var/run/prysm/jwtsecret";
  };

  checkpoint-sync-url = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      URL of a synced beacon node to trust in obtaining checkpoint sync data.
      As an additional safety measure, it is strongly recommended to only use this option in conjunction with --wss-checkpoint flag
    '';
    example = "https://goerli.checkpoint-sync.ethpandaops.io";
  };

  disable-deposit-contract-sync = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Explicitly disables syncing of deposit logs from the execution node.
      This overrides any previous option that depends on it.
      Useful if you intend to run a non-validating beacon node.
    '';
  };

  genesis-state-url = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      URL of a synced beacon node to trust for obtaining genesis state.
      As an additional safety measure, it is strongly recommended to only use this option in conjunction with --wss-checkpoint flag
    '';
    example = "https://goerli.checkpoint-sync.ethpandaops.io";
  };

  disable-quic = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Disables the quic transport.
      The node will rely solely on the TCP transport for libp2p connections.
    '';
  };

  discovery-port = mkOption {
    type = types.port;
    default = 9000;
    description = "The port used by discv5.";
  };

  quic-port = mkOption {
    type = types.port;
    default = config.args.discovery-port + 1;
    defaultText = literalExpression "args.discovery-port + 1";
    description = ''
      The port used by libp2p.
      Will use TCP if disable-quic is set
    '';
  };

  metrics = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Prometheus metrics exporter.";
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host used to listen and respond with metrics for prometheus.";
    };

    port = mkOption {
      type = types.port;
      default = 5054;
      description = "Port used to listen and respond with metrics for prometheus.";
    };
  };

  http = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the HTTP RPC server";
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host on which the RPC server should listen.";
    };

    port = mkOption {
      type = types.port;
      default = 5052;
      description = "RPC port exposed by a beacon node.";
    };
  };

  disable-upnp = mkOption {
    type = types.bool;
    default = true;
    description = "Disable the UPnP configuration";
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Data directory for the databases.";
  };

  user = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "User to run the systemd service.";
  };
}
