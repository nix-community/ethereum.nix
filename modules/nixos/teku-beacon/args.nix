{
  lib,
  name,
  ...
}:
with lib;
{
  network = mkOption {
    type = types.enum [
      "mainnet"
      "holesky"
      "hoodi"
      "ephemery"
      "sepolia"
      "minimal"
      "gnosis"
      "chiado"
      "lukso"
    ];
    default = name;
    defaultText = "name";
    description = "The predefined network configuration.";
  };

  ee-endpoint = mkOption {
    type = types.str;
    default = "http://127.0.0.1:8551";
    description = ''
      The URL of the execution client's Engine JSON-RPC APIs.
    '';
  };

  p2p-port = mkOption {
    type = types.port;
    default = 9000;
    description = "The P2P listening ports (UDP and TCP).";
  };

  p2p-nat-method = mkOption {
    type = types.enum [
      "NONE"
      "UPNP"
    ];
    default = "NONE";
    description = "The method for handling NAT environments.";
  };

  ee-jwt-secret-file = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      The shared secret used to authenticate execution clients when using the Engine JSON-RPC API. Contents of file must be 32 hex-encoded bytes. This can be a relative or absolute path.
    '';
    example = "/var/run/teku/jwtsecret";
  };

  checkpoint-sync-url = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      The URL of a Checkpointz endpoint used to start Teku from a recent state.
    '';
    example = "https://checkpoint-sync.goerli.ethpandaops.io";
  };

  doppelganger-detection-enabled = mkOption {
    type = types.bool;
    default = false;
    description = "Enables or disables doppelganger detection.";
  };

  data-storage-mode = mkOption {
    type = types.nullOr (
      types.enum [
        "archive"
        "minimal"
        "prune"
      ]
    );
    default = "minimal";
    description = "The strategy for handling historical chain data.";
  };

  validators-graffiti = mkOption {
    type = types.str;
    default = "";
    description = "The graffiti to add when creating a block. This is converted to bytes and padded to Bytes32.";
  };

  validators-proposer-default-fee-recipient = mkOption {
    type = types.str;
    default = ""; # TODO: default unspecified, needs to be specified if we have validator keys
    description = "The default recipient of transaction fees for all validator keys. When running a validator, this is an alternative to the `fee_recipient` in the default proposer configuration.";
  };

  validator-keys = mkOption {
    type = types.listOf types.str;
    default = [ ];
    description = "The directory or file to load the encrypted keystore files and associated password files from. Keystore files must use the .json file extension, and password files must use the .txt file extension.

    When specifying directories, Teku expects to find identically named keystore and password files. For example validator_217179e.json and validator_217179e.txt.

    When specifying file names, Teku expects that the files exist.";
  };

  rest-api = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enables or disables the REST API service.";
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The interface on which the REST API listens.";
    };

    port = mkOption {
      type = types.port;
      default = 5051;
      description = "The REST API listening port (HTTP).";
    };

    cors-origins = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "A list of domain URLs for CORS validation.";
    };
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
      description = "The host on which Prometheus accesses Teku metrics.";
    };

    port = mkOption {
      type = types.port;
      default = 8008;
      description = "The port (TCP) on which Prometheus accesses Teku metrics.";
    };
  };

  data-path = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "The path to the Teku data directory. Defaults to '%S/teku-beacon-\<name\>', which generally resolves to /var/lib/teku-beacon-\<name\>.";
  };

  user = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "User to run the systemd service.";
  };
}
