# Module Migration Guide: RFC 42 Settings Pattern

This document describes the approach for migrating ethereum.nix modules from the legacy `args` pattern to the RFC 42 `settings` pattern with `freeformType`.

## Overview

RFC 42 recommends using structured `settings` options instead of manually declared args. This allows:

- Unknown options to pass through via `freeformType`
- Better composability with `mkDefault`/`mkForce`
- Less boilerplate when upstream adds new CLI flags
- Cleaner module code

## Migration Steps

### 1. Delete `args.nix`

Remove the `args.nix` file entirely. Options move to either:

- Explicit `settings` options (for required/special-handling options)
- `freeformType` (for everything else)

### 2. Update `options.nix`

Replace the `args` pattern with `settings` submodule:

```nix
{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  moduleOpts = {
    options = {
      enable = mkEnableOption "Service description";

      package = mkOption {
        type = types.package;
        default = pkgs.example;
        defaultText = literalExpression "pkgs.example";
        description = "Package to use.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;

          options = {
            # Only declare options that:
            # 1. Are required (no default)
            # 2. Need special handling (enums -> flags, etc.)
            # 3. Are commonly used and benefit from documentation
          };
        };
        default = {};
        description = ''
          Service configuration. Converted to CLI arguments.
          See upstream documentation for available options.
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to the service.";
      };
    };
  };
in {
  options.services.ethereum.example = mkOption {
    type = types.attrsOf (types.submodule moduleOpts);
    default = {};
    description = "Specification of one or more service instances.";
  };
}
```

### 3. Update `default.nix`

Replace `mkArgs` with `lib.cli.toCommandLine`:

```nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs' nameValuePair;
  inherit (lib) concatStringsSep mapAttrs;
  inherit (builtins) isList;

  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) baseServiceConfig;

  eachInstance = config.services.ethereum.example;

  # Convert lists to comma-separated strings (if needed by upstream CLI)
  processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);
in {
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  config = mkIf (eachInstance != {}) {
    systemd.services =
      mapAttrs'
      (
        instanceName: cfg: let
          serviceName = "example-${instanceName}";

          cliArgs = lib.cli.toCommandLine (name: {
            option = "-${name}";
            sep = null;
            explicitBool = false;
          }) (processSettings cfg.settings);

          scriptArgs = concatStringsSep " \\\n  " (cliArgs ++ cfg.extraArgs);
        in
          nameValuePair serviceName (mkIf cfg.enable {
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            description = "Example Service (${instanceName})";

            serviceConfig = mkMerge [
              baseServiceConfig
              {
                User = serviceName;
                StateDirectory = serviceName;
                ExecStart = "${cfg.package}/bin/example ${scriptArgs}";
              }
            ];
          })
      )
      eachInstance;
  };
}
```

## Using `lib.cli` from nixpkgs

Use `lib.cli.toCommandLine` instead of custom CLI argument generators.

### Available Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `toCommandLine` | `[list]` | Fully customizable via `optionFormat` |
| `toCommandLineShell` | `"string"` | Same + shell-escaped |
| `toCommandLineGNU` | `[list]` | GNU-style with options |
| `toCommandLineShellGNU` | `"string"` | GNU-style + shell-escaped |

### `toCommandLine` — Most Flexible

```nix
lib.cli.toCommandLine (name: {
  option = "-${name}";     # flag format
  sep = null;              # null = space, "=" = joined
  explicitBool = false;    # false: true→flag, false→omitted
                           # true: both rendered as values
}) { foo = "bar"; verbose = true; }
# → [ "-foo" "bar" "-verbose" ]
```

### `toCommandLineGNU` — GNU-style

```nix
lib.cli.toCommandLineGNU {} { v = true; verbose = true; file = "x"; }
# → [ "-v" "--verbose" "--file=x" ]
```

GNU conventions:

- Short options (1 char): `-v`
- Long options: `--verbose`
- Long options use `=`: `--file=x`

### Which to Use?

| CLI Style | Function |
|-----------|----------|
| `-flag value` (mev-boost) | `toCommandLine` with `option = "-${name}"` |
| `--flag value` (reth) | `toCommandLine` with `option = "--${name}"` |
| GNU-compatible (`-v`, `--file=x`) | `toCommandLineGNU` |
| Need shell string, not list | `*Shell` variants |

### Example: mev-boost

```nix
# Convert lists to comma-separated (mev-boost expects -relays a,b,c)
processSettings = mapAttrs (_: v: if isList v then concatStringsSep "," v else v);

cliArgs = lib.cli.toCommandLine (name: {
  option = "-${name}";
  sep = null;
  explicitBool = false;
}) (processSettings cfg.settings);
```

### Example: reth

```nix
cliArgs = lib.cli.toCommandLine (name: {
  option = "--${name}";
  sep = null;
  explicitBool = false;
}) normalSettings;
```

### Flat Keys for Dotted Options

Use flat dotted keys instead of nested attrs:

```nix
# Good - flat keys
settings = {
  http = true;              # → --http
  "http.addr" = "0.0.0.0";  # → --http.addr 0.0.0.0
};

# Avoid - nested attrs (lib.cli doesn't support)
settings = {
  http.enable = true;
  http.addr = "0.0.0.0";
};
```

## What to Remove

### 1. Deprecated Networks

Remove networks that are no longer active (e.g., holesky, zhejiang, goerli).

### 2. Non-Existent Options

Check upstream documentation and remove options that don't exist.

### 3. Backup/Restore Mixins (for Stateless Services)

If the service doesn't store state (like mev-boost), remove:

```nix
# Remove these
backup = let
  inherit (import ../backup/lib.nix lib) options;
in options;

restore = let
  inherit (import ../restore/lib.nix lib) options;
in options;
```

## Deciding What Options to Declare Explicitly

| Category | Example | Declare Explicitly? |
|----------|---------|---------------------|
| Required (no sensible default) | `relays` | Yes |
| Special handling needed | `network` (enum->flag) | Yes |
| Commonly used | `addr`, `port` | Optional |
| Rarely used | `request-timeout-*` | No, use freeform |
| New upstream options | Any future flags | No, freeform handles it |

## Testing

Update `default.test.nix` to use new `settings` format:

```nix
{
  systems = ["x86_64-linux"];

  module = {
    name = "example";

    nodes = {
      basic = {
        services.ethereum.example.test = {
          enable = true;
          settings = {
            # Use settings instead of args
            addr = "localhost:8080";
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("example-test.service")
    '';
  };
}
```

Run test:

```bash
nix build .#checks.x86_64-linux.testing-example-default.driver
./result/bin/nixos-test-driver
```

## Migration Priority

Start with simpler modules and progress to complex ones:

| Priority | Module | Complexity | Notes |
|----------|--------|------------|-------|
| 1 | mev-boost | Low | Done - good reference |
| 2 | reth | Low | Dot-separated args |
| 3 | geth | Medium | Standard dash-separated |
| 4 | prysm-beacon | Medium | Has --accept-terms-of-use |
| 5 | teku-beacon | Medium | Underscore/dash mix |
| 6 | lighthouse-beacon | High | Complex boolean reconstruction |
| 7 | nimbus-beacon | High | Equals-separated format |
| 8 | nethermind | High | Custom formatting, deep nesting |

## References

- [RFC 42: NixOS settings options](https://github.com/NixOS/rfcs/blob/master/rfcs/0042-config-option.md)
- [Discussion #325: Module System Consideration](https://github.com/nix-community/ethereum.nix/discussions/325)
- [mev-boost migration commit](./modules/mev-boost/) - reference implementation
