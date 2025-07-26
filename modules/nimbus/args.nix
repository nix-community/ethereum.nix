lib:
with lib; {
  port = mkOption {
    type = types.int;
    description = "Port to open";
  };
  network = mkOption {
    type = types.str;
    description = "Network";
  };
  jwtsecret = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Path to the token that ensures safe connection between CL and EL.";
  };
}
