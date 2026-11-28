# Eval-only checks for the NixOS modules. No VM is started and nothing is
# built for the evaluated systems, so this runs on every host system.
{ pkgs, flake, ... }:
let
  inherit (flake.inputs.nixpkgs) lib;

  base = {
    boot.loader.grub.enable = false;
    fileSystems."/" = {
      device = "/dev/null";
      fsType = "ext4";
    };
    system.stateVersion = "25.05";
  };

  eval =
    system: modules:
    (lib.nixosSystem {
      inherit system;
      modules = [ base ] ++ modules;
    }).config;

  # ExecStart split into arguments, without the `\` line continuations.
  tokens =
    s: lib.filter (t: lib.isString t && t != "" && t != "\\") (builtins.split "[[:space:]]+" s);
  countToken = t: ts: lib.count (x: x == t) ts;
  countPair =
    a: b: ts:
    lib.count (p: p.fst == a && p.snd == b) (lib.zipLists ts (lib.drop 1 ts));

  # Importing `default` together with single modules must not declare their
  # options twice, and `package` must default to this flake's build.
  x86 = eval "x86_64-linux" [
    flake.nixosModules.default
    flake.nixosModules.geth
    flake.nixosModules.lighthouse-beacon
    {
      services.ethereum.geth.sepolia = {
        enable = true;
        settings.sepolia = true;
      };
      services.ethereum.lighthouse-beacon = {
        explicit = {
          enable = true;
          settings.network = "sepolia";
        };
        shorthand = {
          enable = true;
          settings.sepolia = true;
        };
        both = {
          enable = true;
          settings = {
            network = "sepolia";
            sepolia = true;
          };
        };
        conflict = {
          enable = true;
          settings = {
            network = "sepolia";
            mainnet = true;
          };
        };
      };
    }
  ];
  execStart = name: tokens x86.systemd.services.${name}.serviceConfig.ExecStart;

  gethDefault = lib.head (execStart "geth-sepolia") == "${flake.packages.x86_64-linux.geth}/bin/geth";

  # `network = "sepolia"`, `sepolia = true`, or both: `--network sepolia` once.
  lighthouseNetworkOnce =
    name:
    let
      ts = execStart "lighthouse-beacon-${name}";
    in
    countToken "--network" ts == 1 && countPair "--network" "sepolia" ts == 1;

  # Two different networks must fail the module's assertion.
  assertionFor =
    name: lib.findFirst (a: lib.hasPrefix "Lighthouse Beacon ${name} " a.message) null x86.assertions;
  conflictRejected = (assertionFor "conflict").assertion or true == false;
  bothAccepted = (assertionFor "both").assertion or false;

  # ethereum.nix doesn't build lighthouse for aarch64-linux. The default must
  # fail with the module's `throw` (catchable by tryEval), not with an
  # uncatchable "attribute 'lighthouse' missing". The `explicit` instance is
  # the positive control: the same config with `package` set must evaluate,
  # so the negative result can only come from the default.
  armHasLighthouse = flake.packages.aarch64-linux ? lighthouse;
  arm = eval "aarch64-linux" [
    flake.nixosModules.lighthouse-beacon
    (
      { pkgs, ... }:
      {
        services.ethereum.lighthouse-beacon = {
          default.enable = true;
          explicit = {
            enable = true;
            package = pkgs.writeShellScriptBin "lighthouse" "";
          };
        };
      }
    )
  ];
  armExecStart =
    name: builtins.tryEval arm.systemd.services."lighthouse-beacon-${name}".serviceConfig.ExecStart;
in
assert lib.assertMsg gethDefault "geth ExecStart does not use ethereum.nix's geth";
assert lib.assertMsg (lighthouseNetworkOnce "explicit")
  "lighthouse-beacon with network = \"sepolia\" must pass --network sepolia exactly once";
assert lib.assertMsg (lighthouseNetworkOnce "shorthand")
  "lighthouse-beacon with sepolia = true must pass --network sepolia exactly once";
assert lib.assertMsg (lighthouseNetworkOnce "both")
  "lighthouse-beacon with network = \"sepolia\" and sepolia = true must pass --network sepolia exactly once";
assert lib.assertMsg bothAccepted "lighthouse-beacon must accept the same network set both ways";
assert lib.assertMsg conflictRejected "lighthouse-beacon must reject two different networks";
assert lib.assertMsg (
  !armHasLighthouse
) "lighthouse is now built for aarch64-linux; pick another package for the missing-package check";
assert lib.assertMsg (armExecStart "explicit").success
  "positive control: lighthouse-beacon on aarch64-linux with an explicit package must evaluate";
assert lib.assertMsg (
  !(armExecStart "default").success
) "package default for a system ethereum.nix doesn't build should throw";
pkgs.runCommand "nixos-modules-eval" { } "touch $out"
