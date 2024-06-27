lib:
with lib; {
  network = mkOption {
    type = types.nullOr (types.enum ["mainnet" "goerli" "sepolia" "zhejiang"]);
    default = null;
    description = "The network to connect to. Mainnet (null) is the default ethereum network.";
  };

  relays = mkOption {
    type = types.listOf types.str;
    description = "relay urls";
  };

  relay-monitors = mkOption {
    type = types.nullOr (types.listOf types.str);
    default = null;
    description = "relay urls";
  };

  relay-check = mkOption {
    type = types.bool;
    default = false;
    description = "check relay status on startup and on the status API call";
  };

  request-max-retries = mkOption {
    type = types.int;
    default = 5;
    description = "maximum number of retries for a relay get payload request";
  };

  request-timeout-getheader = mkOption {
    type = types.int;
    default = 950;
    description = "timeout for getHeader requests to the relay [ms]";
  };

  request-timeout-getpayload = mkOption {
    type = types.int;
    default = 4000;
    description = "timeout for getPayload requests to the relay [ms]";
  };

  request-timeout-regval = mkOption {
    type = types.int;
    default = 3000;
    description = "timeout for registerValidator requests [ms]";
  };

  min-bid = mkOption {
    type = types.nullOr types.float;
    default = null;
    description = "minimum bid to accept from a relay [eth]";
  };

  loglevel = mkOption {
    type = types.nullOr (types.enum ["trace" "debug" "info" "warn" "error" "fatal" "panic"]);
    default = "info";
    description = "minimum loglevel";
  };

  json = mkOption {
    type = types.bool;
    default = false;
    description = "log in JSON format instead of text";
  };

  log-no-version = mkOption {
    type = types.bool;
    default = false;
    description = "disables adding the version to every log entry";
  };

  log-service = mkOption {
    type = types.bool;
    default = false;
    description = "add a 'service=...' tag to all log messages";
  };

  addr = mkOption {
    type = types.str;
    default = "localhost:18550";
    description = "listen-address for mev-boost server (default 'localhost:18550')";
  };
}
