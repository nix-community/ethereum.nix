lib: with lib; {
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
    example = "https://eth-mainnet.alchemyapi.io/v2/YOUR_API_KEY";
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

  fallbackRpc = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Fallback RPC used if the checkpoint is too outdated for Helios to sync.";
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Data directory for persisting sync state. Defaults to '%S/helios-<name>'.";
    example = "/var/lib/helios/mainnet";
  };
}
