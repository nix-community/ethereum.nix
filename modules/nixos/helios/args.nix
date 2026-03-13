lib:
with lib; {
  network = mkOption {
    type = types.enum [
      "ethereum"
      "optimism"
      "base"
    ];
    default = "ethereum";
    description = "The network to sync. Use 'ethereum' for mainnet, or 'optimism'/'base' for OP Stack chains.";
  };

  executionRpc = mkOption {
    type = types.str;
    description = "The execution layer RPC endpoint URL.";
  };

  checkpoint = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "A trusted checkpoint hash. Must be the first beacon block hash of an epoch.";
  };

  rpc = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the Helios JSON-RPC server.";
    };

    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The address for the JSON-RPC server to bind to.";
    };

    port = mkOption {
      type = types.port;
      default = 8545;
      description = "The port for the JSON-RPC server to listen on.";
    };
  };

  checkpointFallback = mkOption {
    type = types.nullOr types.str;
    default = null;
    example = "https://sync-mainnet.beaconcha.in";
    description = "A fallback checkpoint sync URL used when the configured checkpoint is too outdated. Helios will query this endpoint for a recent weak subjectivity checkpoint.";
  };

  loadExternalFallback = mkOption {
    type = types.bool;
    default = false;
    description = "Enable fallback to community-maintained checkpoint sync APIs when the configured checkpoint is outdated. Uses the ethpandaops/checkpoint-sync-health-checks list. WARNING: no security guarantees are provided; use as a last resort.";
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Data directory for persisting sync state. Defaults to '%S/helios-<name>'.";
    example = "/var/lib/helios/mainnet";
  };
}
