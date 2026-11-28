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

  # The `package` option of a module, defaulting to ethereum.nix's own build.
  #
  # `flake` is ethereum.nix itself, never the consuming flake: every
  # `modules/nixos/<name>/default.nix` is wrapped in `{ flake, ... }:`, which
  # blueprint calls with this flake (its publisher args) before exporting the
  # module. Modules must therefore be imported through
  # `nixosModules.<name>`; path imports are unsupported.
  mkFlakePackageOption =
    {
      flake,
      pkgs,
      # attribute name in ethereum.nix's `packages.<system>`
      package,
      # e.g. "services.ethereum.geth", used in the error message
      optionPath,
      description,
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    lib.mkOption {
      type = lib.types.package;
      default =
        flake.packages.${system}.${package}
          or (throw "ethereum.nix does not build ${package} for ${system}; set ${optionPath}.<name>.package");
      defaultText = lib.literalExpression "inputs.ethereum-nix.packages.\${pkgs.stdenv.hostPlatform.system}.${package}";
      inherit description;
    };
in
{
  inherit baseServiceConfig mkFlakePackageOption;
}
