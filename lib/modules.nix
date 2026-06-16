lib:
let
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
    SystemCallFilter = lib.mkDefault [
      "@system-service"
      "~@privileged"
    ];
  };
in
{
  inherit baseServiceConfig;
}
