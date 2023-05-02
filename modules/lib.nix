lib: let
  inherit (builtins) isString toString isList;
  inherit (lib) types;
  inherit (lib.options) isOption;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.asserts) assertMsg;
  inherit (lib.attrsets) attrByPath hasAttrByPath mapAttrsRecursiveCond collect;

  defaultArgReducer = value:
    if (isList value)
    then concatStringsSep "," value
    else toString value;

  defaultPathReducer = path: let
    arg = concatStringsSep "-" path;
  in "--${arg}";

  dotPathReducer = path: let
    arg = concatStringsSep "." path;
  in "--${arg}";

  defaultArgFormatter = {
    opt,
    path,
    value,
    argReducer ? defaultArgReducer,
    pathReducer ? defaultPathReducer,
  }: let
    arg = pathReducer path;
  in
    if (opt.type == types.bool)
    then
      (
        if value
        then "${arg}"
        else ""
      )
    else "${arg} ${argReducer value}";

  mkArg = {
    path,
    opt,
    args,
    argFormatter ? defaultArgFormatter,
    argReducer ? defaultArgReducer,
    pathReducer ? defaultPathReducer,
  }: let
    value = attrByPath path opt.default args;
    hasValue = (hasAttrByPath path args) && value != null;
    hasDefault = (hasAttrByPath ["default"] opt) && value != null;
  in
    assert assertMsg (isOption opt) "opt must be an option";
      if (hasValue || hasDefault)
      then (argFormatter {inherit opt path value argReducer pathReducer;})
      else "";

  mkArgs = {
    opts,
    args,
    argFormatter ? defaultArgFormatter,
    argReducer ? defaultArgReducer,
    pathReducer ? defaultPathReducer,
  }:
    collect (v: (isString v) && v != "") (
      mapAttrsRecursiveCond
      (as: !isOption as)
      (path: opt: mkArg {inherit path opt args argFormatter argReducer pathReducer;})
      opts
    );

  baseServiceConfig = with lib; {
    Restart = mkDefault "on-failure";

    # https://www.freedesktop.org/software/systemd/man/systemd.exec.html#DynamicUser=
    # Enabling dynamic user implies other options which cannot be changed:
    #   * RemoveIPC = true
    #   * PrivateTmp = true
    #   * NoNewPrivileges = "strict"
    #   * RestrictSUIDSGID = true
    #   * ProtectSystem = "strict"
    #   * ProtectHome = "read-only"
    DynamicUser = mkDefault true;

    ProtectClock = mkDefault true;
    ProtectProc = mkDefault "noaccess";
    ProtectKernelLogs = mkDefault true;
    ProtectKernelModules = mkDefault true;
    ProtectKernelTunables = mkDefault true;
    ProtectControlGroups = mkDefault true;
    ProtectHostname = mkDefault true;
    PrivateDevices = mkDefault true;
    RestrictRealtime = mkDefault true;
    RestrictNamespaces = mkDefault true;
    LockPersonality = mkDefault true;
    MemoryDenyWriteExecute = mkDefault true;
    SystemCallFilter = lib.mkDefault ["@system-service" "~@privileged"];
  };
in {
  inherit baseServiceConfig;
  inherit mkArg mkArgs defaultPathReducer defaultArgReducer defaultArgFormatter dotPathReducer;

  findEnabled = with lib;
    tree: let
      op = sum: path: val: let
        pathStr = concatStringsSep "-" path;
      in
        if (attrByPath ["enable"] false val)
        then (sum // {"${pathStr}" = val;})
        else if (isAttrs val)
        then (recurse sum path val)
        else sum;

      recurse = sum: path: val:
        foldl'
        (sum: key: op sum (path ++ [key]) val.${key})
        sum (attrNames val);
    in
      recurse {} [] tree;
}
