lib:
with lib; {
  addr = mkOption {
    # todo use regex matching
    type = types.str;
    default = ":30301";
    description = mdDoc "Listen address";
  };

  genkey = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Generate a node key";
  };

  nat = mkOption {
    # todo use regex matching
    type = types.str;
    default = "none";
    description = mdDoc "Port mapping mechanism (any|none|upnp|pmp|pmp:<IP>|extip:<IP>)";
  };

  netrestrict = mkOption {
    # todo use regex matching
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Restrict network communication to the given IP networks (CIDR masks)";
  };

  nodekey = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = mdDoc "Private key filename";
  };

  nodekeyhex = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Private key as hex (for testing)";
  };

  v5 = mkOption {
    type = types.nullOr types.bool;
    default = null;
    description = mdDoc "Run a V5 topic discovery bootnode";
  };

  verbosity = mkOption {
    type = types.ints.between 0 5;
    default = 3;
    description = mdDoc "log verbosity (0-5)";
  };

  vmodule = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = mdDoc "Log verbosity pattern";
  };

  writeaddress = mkOption {
    type = types.nullOr types.bool;
    default = null;
    description = mdDoc "Write out the node's public key and quit";
  };
}
