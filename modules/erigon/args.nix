lib:
with lib; {
  port = mkOption {
    type = types.port;
    default = 30303;
    description = mdDoc "Network listening port.";
  };

  snapshots = mkOption {
    type = types.bool;
    default = true;
    description = mdDoc ''
      Default: use snapshots "true" for BSC, Mainnet and Goerli. use snapshots "false" in all other cases.
    '';
  };

  externalcl = mkEnableOption (mdDoc "enables external consensus");

  chain = mkOption {
    type = types.enum [
      "mainnet"
      "rinkeby"
      "goerli"
      "sokol"
      "fermion"
      "mumbai"
      "bor-mainnet"
      "bor-devnet"
      "sepolia"
      "gnosis"
      "chiado"
    ];
    default = "mainnet";
    description = mdDoc "Name of the network to join. If null the network is mainnet.";
  };

  torrent = {
    port = mkOption {
      type = types.port;
      default = 42069;
      description = mdDoc "Port to listen and serve BitTorrent protocol .";
    };
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

    compression = mkEnableOption (mdDoc "Enable compression over HTTP-RPC.");

    corsdomain = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mdDoc "List of domains from which to accept cross origin requests.";
      example = ["*"];
    };

    vhosts = mkOption {
      type = types.listOf types.str;
      default = ["localhost"];
      description = mdDoc ''
        Comma separated list of virtual hostnames from which to accept requests (server enforced).
        Accepts '*' wildcard.
      '';
      example = ["localhost" "erigon.example.org"];
    };

    api = mkOption {
      type = types.nullOr (types.listOf types.str);
      description = mdDoc "API's offered over the HTTP-RPC interface.";
      example = ["net" "eth"];
    };

    trace = mkEnableOption (mdDoc "Trace HTTP requests with INFO level");

    timeouts = {
      idle = mkOption {
        type = types.str;
        default = "2m0s";
        description = ''
          Maximum amount of time to wait for the next request when keep-alives are enabled. If http.timeouts.idle
          is zero, the value of http.timeouts.read is used.
        '';
        example = "30s";
      };
      read = mkOption {
        type = types.str;
        default = "30s";
        description = "Maximum duration for reading the entire request, including the body.";
        example = "30s";
      };
      write = mkOption {
        type = types.str;
        default = "30m0s";
        description = ''
          Maximum duration before timing out writes of the response. It is reset whenever a new request's
          header is read.
        '';
        example = "30m0s";
      };
    };
  };

  ws = {
    enable = mkEnableOption (mdDoc "Erigon WebSocket API");
    compression = mkEnableOption (mdDoc "Enable compression over HTTP-RPC.");
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

    vhosts = mkOption {
      type = types.listOf types.str;
      default = ["localhost"];
      description = mdDoc ''
        Comma separated list of virtual hostnames from which to accept Engine API requests
        (server enforced). Accepts '*' wildcard."
      '';
      example = ["localhost" "erigon.example.org"];
    };

    jwtsecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Path to the token that ensures safe connection between CL and EL.";
      example = "/var/run/erigon/jwtsecret";
    };

    timeouts = {
      idle = mkOption {
        type = types.str;
        default = "2m0s";
        description = ''
          Maximum amount of time to wait for the next request when keep-alives are enabled. If http.timeouts.idle
          is zero, the value of http.timeouts.read is used.
        '';
        example = "30s";
      };
      read = mkOption {
        type = types.str;
        default = "30s";
        description = "Maximum duration for reading the entire request, including the body.";
        example = "30s";
      };
      write = mkOption {
        type = types.str;
        default = "30m0s";
        description = ''
          Maximum duration before timing out writes of the response. It is reset whenever a new request's
          header is read.
        '';
        example = "30m0s";
      };
    };
  };

  private.api = {
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1:9090";
      description = mdDoc ''
        Private api network address, for example: 127.0.0.1:9090, empty string means not to start the listener. Do not expose to public network. Serves remote database interface.
      '';
    };
    ratelimit = mkOption {
      type = types.int;
      default = 31872;
      description = mdDoc ''
        Amount of requests server handle simultaneously - requests over this limit will wait. Increase it - if clients see 'request timeout' while server load is low - it means your 'hot data' is small or have much RAM.
      '';
    };
  };

  metrics = {
    enable = mkEnableOption (mdDoc "Enable metrics collection and reporting.");

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
}
