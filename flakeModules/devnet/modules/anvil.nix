{
  lib,
  pkgs,
  ...
}:
with lib; let
  jsonFormat = pkgs.formats.json {};
in {
  # Schema
  options = {
    enable = mkEnableOption "Enable Anvil development network.";

    package = mkPackageOption pkgs "foundry" {};

    settings = {
      fork = {
        computeUnitsPerSecond = mkOption {
          type = type.int;
          description = ''
            Sets the number of assumed available compute units per second for this provider.
          '';
          default = 330;
        };

        forkUrl = mkOption {
          type = with types; nullOr str;
          description = ''
            Fetch state over a remote endpoint instead of starting from an empty state.

            If you want to fetch state from a specific block number, add a block number like `http://localhost:8545@1400000` or use the `forkBlockNumber` argument.
          '';
        };

        forkBlockNumber = mkOption {
          type = with types; nullOr int;
          description = "Fetch state from a specific block number over a remote endpoint.";
        };

        forkChainId = mkOption {
          type = with types; nullOr str;
          description = ''
            Specify chain id to skip fetching it from remote endpoint. This enables offline-start mode.

            You still must pass both `forkUrl` and `forkBlockNumber` and already have your reequired state cached on disk, anything missing locally would be fetched from the remote.
          '';
        };

        forkRetryBackoff = mkOption {
          type = with types; nullOr int;
          description = "Initial retry backoff on encountering errors.";
        };

        noRateLimit = mkOption {
          type = types.bool;
          description = "Disables rate limiting for this node's provider.";
          default = false;
        };

        noStorageCaching = mkOption {
          type = types.bool;
          description = ''
            Explicitly disables the use of RPC caching.

            All storage slots are read entirely from the endpoint.

            This flag overrides the project's configuration file.
          '';
          default = false;
        };

        retries = mkOption {
          type = with types; nullOr int;
          description = "Number of retry requests for spurious networks (timed out requests)";
          default = 5;
        };

        timeout = mkOption {
          type = with types; nullOr int;
          description = "Timeout in ms for requests sent to remote JSON-RPC server in forking mode.";
          default = 45000;
        };
      };

      environment = {
        blockBaseFeePerGas = mkOption {
          type = with types; nullOr int str;
          description = "The base fee in a block.";
        };

        chainId = mkOption {
          type = with types; nullOr int str;
          description = "The chain ID.";
        };

        codeSizeLimit = mkOption {
          type = with types; nullOr int str;
          description = ''
            EIP-170: Contract code size limit in bytes. Useful to increase this because of tests. By default, it is 0x6000 (~25kb).
          '';
        };

        disableBlockGasLimit = mkOption {
          type = types.bool;
          description = ''
            Disable the `call.gas_limit <= block.gas_limit` constraint.
          '';
          default = false;
        };

        gasLimit = mkOption {
          type = with types; nullOr int str;
          description = "The block gas limit.";
        };

        gasPrice = mkOption {
          type = with types; nullOr int str;
          description = "The gas price.";
        };
      };

      server = {
        allowOrigin = mkOption {
          type = with types; nullOr str;
          description = "Set the CORS allow origin header.";
          default = "*";
        };

        blockTime = mkOption {
          type = with types; nullOr int;
          description = "Block time in seconds for interval mining.";
        };

        configOut = mkOption {
          type = with types; nullOr path;
          description = "Writes output of `anvil` as json to user-specified file.";
        };

        dumpState = mkOption {
          type = with types; nullOr path;
          description = ''
            Dump the state of chain on exit to the given file.

            If the value is a directory, the state will be written to `<VALUE>/state.json`.
          '';
        };

        hardFork = mkOption {
          type = with types; nullOr (enum ["latest" "shanghai" "paris" "london"]);
          description = "Block time in seconds for interval mining.";
          default = "latest";
        };

        host = mkOption {
          type = with types; nullOr str;
          description = "The host the server will listen on.";
          example = "0.0.0.0";
          default = "127.0.0.1";
        };

        port = mkOption {
          type = types.port;
          description = "Port number to listen on.";
          default = 8545;
        };

        init = mkOption {
          type = with types; nullOr path jsonFormat.type;
          description = "Initialize the genesis block with the given `genesis.json` file.";
        };

        ipc = mkOption {
          type = with types; nullOr path;
          description = "Launch an ipc server at the given path.";
          example = "/tmp/anvil.ipc";
        };

        loadState = mkOption {
          type = with types; nullOr path;
          description = "Initialize the chain from a previously saved state snapshot.";
        };

        noCors = mkOption {
          type = types.bool;
          description = "Disables CORS.";
          default = false;
        };

        noMining = mkOption {
          type = types.bool;
          description = "Disable auto and interval mining, and mine on demand instead.";
          default = false;
        };

        order = mkOption {
          type = with types; nullOr str;
          description = "How transactions are sorted in the mempool.";
          default = "fees";
        };

        pruneHistory = mkOption {
          type = with types; nullOr int;
          description = "Don't keep full chain history. If a number argument is specified, at most this number of states is kept in memory.";
        };

        stateInterval = mkOption {
          type = with types; nullOr int;
          description = "Interval in seconds at which the status is to be dumped to disk.";
        };

        silent = mkOption {
          type = with types; nullOr bool;
          description = "Don't print anything on startup and don't print logs.";
        };

        transactionBlockKeeper = mkOption {
          types = with types; nullOr int;
          description = "Number of blocks with transactions to keep in memory.";
        };
      };

      evm = {
        accounts = mkOption {
          types = types.int;
          description = "Number of dev accounts to generate and configure.";
          default = 10;
        };

        balance = mkOption {
          types = types.int;
          description = "The balance of every dev account in Ether.";
          default = 10000;
        };

        derivationPath = mkOption {
          types = types.str;
          description = "Sets the derivation path of the child key to be derived.";
          default = "m/44'/60'/0'/0/";
        };

        mnemonic = mkOption {
          types = with types; nullOr str;
          description = "BIP39 mnemonic phrase used for generating accounts.";
        };

        stepsTracing = mkOption {
          types = types.bool;
          description = "Enable steps tracing used for debug calls returning geth-style traces.";
          default = false;
        };

        timestamp = mkOption {
          types = with types; nullOr int;
          description = "The timestamp of the genesis block.";
        };
      };
    };

    outputs.build.processCompose = {
      preInitCommand = mkOption {
        type = with types; nullOr oneOf [str shellPackage];
        internal = true;
      };

      preTeardownCommand = mkOption {
        type = with types; nullOr oneOf [str shellPackage];
        internal = true;
      };

      configYaml = mkOption {
        type = with types; attrsOf raw;
        internal = true;
      };
    };
  };

  # Config
  config = {};
}
