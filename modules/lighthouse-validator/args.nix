{
  lib,
  name,
  ...
}:
with lib; {
  network = mkOption {
    type = types.nullOr (types.enum ["mainnet" "prater" "goerli" "gnosis" "chiado" "sepolia" "holesky"]);
    default = name;
    defaultText = "name";
    description = "The network to connect to. Mainnet is the default ethereum network.";
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
      default = 5064;
      description = "Port used to listen and respond with metrics for prometheus.";
    };
  };

  http = {
    enable = mkEnableOption "the HTTP REST API server";

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host on which the REST API server should listen.";
    };

    port = mkOption {
      type = types.port;
      default = 5062;
      description = "REST API port exposed by a beacon node.";
    };
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Data directory for the databases.";
  };

  suggested-fee-recipient = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      Sets ALL validators' mapping to a suggested eth
      address to receive gas fees when proposing a block. note
      that this is only a suggestion when integrating with a Builder API,
      which may choose to specify a different fee recipient as payment
      for the blocks it builds.
    '';
  };

  beacon-nodes = mkOption {
    type = with types; nullOr (listOf str);
    default = null;
    description = ''
      List of Lighthouse Beacon node HTTP APIs to connect to.

      When null, looks up the http address+port from the lighthouse
      beacon node service with the same name.
      (eg `services.ethereum.lighthouse-validator.holesky` will look
      at the config of `services.ethereum.lighthouse-beacon.holesky`)
    '';
  };

  graffiti = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "String to include in proposed blocks";
  };

  user = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "User to run the systemd service.";
  };
}
