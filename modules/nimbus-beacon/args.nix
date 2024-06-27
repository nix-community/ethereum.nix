{
  lib,
  name,
  ...
}:
with lib; {
  network = mkOption {
    type = types.enum ["mainnet" "prater" "sepolia" "holesky"];
    default = name;
    defaultText = "name";
    description = "The Eth2 network to join";
  };

  el = mkOption {
    type = types.listOf types.str;
    default = ["http://127.0.0.1:8551"];
    description = ''
      One or more Execution Layer Engine API URLs.
    '';
  };

  listen-address = mkOption {
    type = types.str;
    default = "0.0.0.0";
    description = ''
      Listening address for the Ethereum LibP2P and Discovery v5 traffic
    '';
  };

  tcp-port = mkOption {
    type = types.port;
    default = 9000;
    description = "The port used for LibP2P traffic.";
  };

  udp-port = mkOption {
    type = types.port;
    default = 9000;
    description = "The port used for node discovery.";
  };

  nat = mkOption {
    type = types.str;
    default = "any";
    description = "Specify method to use for determining public address. Must be one of: any, none, upnp, pmp, extip:<IP>";
  };

  enr-auto-update = mkOption {
    type = types.bool;
    default = false;
    description = "Discovery can automatically update its ENR with the IP address and UDP port as seen by other nodes it communicates with. This option allows to enable/disable this functionality.";
  };

  jwt-secret = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      A file containing the hex-encoded 256 bit secret key to be used for verifying/generating JWT tokens.
    '';
    example = "/var/run/nimbus/jwtsecret";
  };

  trusted-node-url = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      URL of a synced beacon node to trust in obtaining checkpoint sync data.
    '';
    example = "https://checkpoint-sync.goerli.ethpandaops.io";
  };

  max-peers = mkOption {
    type = types.str;
    default = "160";
    description = "The target number of peers to connect to";
  };

  doppelganger-detection = mkOption {
    type = types.bool;
    default = true;
    description = "If enabled, the beacon node prudently listens for 2 epochs for attestations from a validator with the same index (a doppelganger), before sending an attestation itself. This protects against slashing (due to double-voting) but means you will miss two attestations when restarting.";
  };

  history = mkOption {
    type = types.nullOr (types.enum ["archive" "prune"]);
    default = "prune";
    description = "Retention strategy for historical data";
  };

  graffiti = mkOption {
    type = types.str;
    default = "";
    description = "The graffiti value that will appear in proposed blocks. You can use a 0x-prefixed hex encoded string to specify raw bytes.";
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

  rest = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the REST server";
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listening address of the REST server";
    };

    port = mkOption {
      type = types.port;
      default = 5052;
      description = "Port for the REST server";
    };

    allow-origin = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Limit the access to the REST API to a particular hostname (for CORS-enabled clients such as browsers).";
    };
  };

  payload-builder = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable external payload builder ";
    };
    url = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Payload builder URL.";
    };
  };
  light-client-data = {
    serve = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to serve data for enabling light clients to stay in sync with the network.";
    };
    import-mode = mkOption {
      type = types.enum ["none" "only-new" "full" "on-demand"];
      default = "only-new";
      description = "Which classes of light client data to import. Must be one of: none, only-new, full (slow startup), on-demand (may miss validator duties).";
    };
    max-periods = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Maximum number of sync committee periods to retain light client data.";
    };
  };

  data-dir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Data directory for the Nimbus databases. Defaults to '%S/nimbus-beacon-\<name\>', which generally resolves to /var/lib/nimbus-beacon-\<name\>.";
  };

  user = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "User to run the systemd service.";
  };
}
