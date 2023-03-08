lib:
with lib; {
  port = mkOption {
    type = types.port;
    default = 30303;
    description = mdDoc "Port number Go Ethereum will be listening on, both TCP and UDP.";
  };

  http = {
    enable = mkEnableOption (mdDoc "Go Ethereum HTTP API");

    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "HTTP-RPC server listening interface";
    };

    port = mkOption {
      type = types.port;
      default = 8545;
      description = mdDoc "Port number of Go Ethereum HTTP API.";
    };

    api = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mdDoc "API's offered over the HTTP-RPC interface";
      example = ["net" "eth"];
    };

    corsdomain = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mdDoc "List of domains from which to accept cross origin requests";
      example = ["*"];
    };

    rpcprefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "HTTP path path prefix on which JSON-RPC is served. Use '/' to serve on all paths.";
      example = "/";
    };

    vhosts = mkOption {
      type = types.listOf types.str;
      default = ["localhost"];
      description = mdDoc ''
        Comma separated list of virtual hostnames from which to accept requests (server enforced).
        Accepts '*' wildcard.
      '';
      example = ["localhost" "geth.example.org"];
    };
  };

  ws = {
    enable = mkEnableOption (mdDoc "Go Ethereum WebSocket API");
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "Listen address of Go Ethereum WebSocket API.";
    };

    port = mkOption {
      type = types.port;
      default = 8546;
      description = mdDoc "Port number of Go Ethereum WebSocket API.";
    };

    api = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = mdDoc "APIs to enable over WebSocket";
      example = ["net" "eth"];
    };
  };

  authrpc = {
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "Listen address of Go Ethereum Auth RPC API.";
    };

    port = mkOption {
      type = types.port;
      default = 8551;
      description = mdDoc "Port number of Go Ethereum Auth RPC API.";
    };

    vhosts = mkOption {
      type = types.listOf types.str;
      default = ["localhost"];
      description = mdDoc "List of virtual hostnames from which to accept requests.";
      example = ["localhost" "geth.example.org"];
    };

    jwtsecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Path to a JWT secret for authenticated RPC endpoint.";
      example = "/var/run/geth/jwtsecret";
    };
  };

  metrics = {
    enable = mkEnableOption (mdDoc "Go Ethereum prometheus metrics");
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "Listen address of Go Ethereum metrics service.";
    };

    port = mkOption {
      type = types.port;
      default = 6060;
      description = mdDoc "Port number of Go Ethereum metrics service.";
    };
  };

  network = mkOption {
    type = types.nullOr (types.enum ["goerli" "kiln" "rinkeby" "ropsten" "sepolia"]);
    default = null;
    description = mdDoc "The network to connect to. Mainnet (null) is the default ethereum network.";
  };

  networkid = mkOption {
    type = types.int;
    default = 1;
    description = mdDoc "The network id used for peer to peer communication";
  };

  netrestrict = mkOption {
    # todo use regex matching
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Restrict network communication to the given IP networks (CIDR masks)";
  };

  verbosity = mkOption {
    type = types.ints.between 0 5;
    default = 3;
    description = mdDoc "log verbosity (0-5)";
  };

  nodiscover = mkOption {
    type = types.bool;
    default = false;
    description = "Disable discovery";
  };

  bootnodes = mkOption {
    # todo use regex matching
    type = types.nullOr (types.listOf types.str);
    default = null;
    description = mdDoc "List of bootnodes to connect to";
  };

  syncmode = mkOption {
    type = types.enum ["snap" "fast" "full" "light"];
    default = "snap";
    description = mdDoc "Blockchain sync mode.";
  };

  gcmode = mkOption {
    type = types.enum ["full" "archive"];
    default = "full";
    description = mdDoc "Blockchain garbage collection mode.";
  };

  maxpeers = mkOption {
    type = types.int;
    default = 50;
    description = mdDoc "Maximum peers to connect to.";
  };
}
