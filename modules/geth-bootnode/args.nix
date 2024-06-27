lib:
with lib; {
  addr = mkOption {
    # todo use regex matching
    type = types.str;
    default = ":30301";
    description = "Listen address";
  };

  genkey = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Generate a node key";
  };

  nat = mkOption {
    # todo use regex matching
    type = types.str;
    default = "none";
    description = "Port mapping mechanism (any|none|upnp|pmp|pmp:IP|extip:IP)";
  };

  netrestrict = mkOption {
    # todo use regex matching
    type = types.nullOr types.str;
    default = null;
    description = "Restrict network communication to the given IP networks (CIDR masks)";
  };

  nodekey = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = "Private key filename";
  };

  nodekeyhex = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Private key as hex (for testing)";
  };

  v5 = mkOption {
    type = types.nullOr types.bool;
    default = null;
    description = "Run a V5 topic discovery bootnode";
  };

  verbosity = mkOption {
    type = types.ints.between 0 5;
    default = 3;
    description = "log verbosity (0-5)";
  };

  vmodule = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Log verbosity pattern";
  };

  writeaddress = mkOption {
    type = types.nullOr types.bool;
    default = null;
    description = "Write out the node's public key and quit";
  };
}
