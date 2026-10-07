{
  config,
  lib,
  pkgs,
  ...
}:
let
  modulesLib = import ../../../lib/modules.nix lib;

  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib)
    filterAttrs
    flatten
    mapAttrs'
    mapAttrsToList
    mkForce
    mkIf
    mkMerge
    nameValuePair
    optionals
    elem
    ;
  inherit (modulesLib) baseServiceConfig;

  eachBeacon = config.services.ethereum.lodestar-beacon;

  settingsFormat = pkgs.formats.yaml { };

  # Converts a nested attrset to a flat attrset with dot-notation string keys,
  # matching Lodestar's YAML config format.
  #
  # Example:
  #   { rest = { address = "0.0.0.0"; port = 9596; }; }
  #   -> { "rest.address" = "0.0.0.0"; "rest.port" = 9596; }
  #
  # Special case: a leaf key named "enable" becomes the parent key, so
  #   { metrics = { enable = true; port = 8008; }; }
  #   -> { "metrics" = true; "metrics.port" = 8008; }
  # This matches Lodestar's convention of "metrics: true" (not "metrics.enable: true").
  flattenDotAttrs =
    prefix: attrs:
    lib.foldlAttrs (
      acc: k: v:
      let
        key = if prefix == "" then k else "${prefix}.${k}";
        outputKey = if k == "enable" && prefix != "" then prefix else key;
      in
      acc
      // (if lib.isAttrs v && !lib.isDerivation v then flattenDotAttrs key v else { ${outputKey} = v; })
    ) { } attrs;
in
{
  ###### interface
  inherit (import ./options.nix { inherit lib pkgs; }) options;

  ###### implementation
  config = mkIf (eachBeacon != { }) {
    # configure the firewall for each service
    networking.firewall =
      let
        openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachBeacon;
        perService = mapAttrsToList (
          _: cfg:
          let
            s = cfg.settings;
          in
          {
            allowedTCPPorts = [ (s.port or 9000) ];
            allowedUDPPorts = [ (s.port or 9000) ];
          }
        ) openFirewall;
      in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services = mapAttrs' (
      beaconName:
      let
        serviceName = "lodestar-beacon-${beaconName}";
      in
      cfg:
      let
        s = cfg.settings;
        dataDir = s.dataDir or "%S/${serviceName}";
        jwtSecret = s.jwtSecret or null;

        # Keys that need systemd specifier expansion (%S, %d), so they can't
        # be baked into the static rcConfig file and are passed as CLI args instead.
        skipKeys = [
          "dataDir"
          "jwtSecret"
        ];
        normalSettings = filterAttrs (k: _: !elem k skipKeys) s;

        rcConfigFile = settingsFormat.generate "${serviceName}-rcConfig.yaml" (
          flattenDotAttrs "" normalSettings
        );

        allArgs = [
          "beacon"
          "--rcConfig"
          (toString rcConfigFile)
          "--dataDir"
          dataDir
        ]
        ++ (optionals (jwtSecret != null) [
          "--jwtSecret"
          "%d/jwt-secret"
        ])
        ++ cfg.extraArgs;

        scriptArgs = lib.concatStringsSep " \\\n  " allArgs;
      in
      nameValuePair serviceName (
        mkIf cfg.enable {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Lodestar Beacon Node (${beaconName})";

          serviceConfig = mkMerge [
            baseServiceConfig
            (mkIf (cfg.user != null) {
              # A statically-managed user is incompatible with DynamicUser.
              DynamicUser = mkForce false;
            })
            {
              User = if cfg.user != null then cfg.user else serviceName;
              StateDirectory = serviceName;
              ExecStart = "${cfg.package}/bin/lodestar ${scriptArgs}";

              # Node.js/V8 requires write+exec pages for JIT compilation.
              MemoryDenyWriteExecute = false;

              # Lodestar's package wraps the binary in bwrap (bubblewrap),
              # which needs to create user/mount namespaces and issue
              # privileged syscalls (unshare, mount, pivot_root, ...) that
              # span multiple syscall groups, making a meaningful
              # SystemCallFilter allowlist impractical.
              RestrictNamespaces = false;
              SystemCallFilter = null;
            }
            (mkIf (jwtSecret != null) {
              LoadCredential = [ "jwt-secret:${jwtSecret}" ];
            })
          ];
        }
      )
    ) eachBeacon;
  };
}
