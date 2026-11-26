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

  plain = s: builtins.unsafeDiscardStringContext s;
  count = needle: s: lib.length (lib.splitString needle s) - 1;

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
      };
    }
  ];
  execStart = name: plain x86.systemd.services.${name}.serviceConfig.ExecStart;

  gethDefault = lib.hasPrefix "${plain flake.packages.x86_64-linux.geth.outPath}/bin/geth " (
    execStart "geth-sepolia"
  );

  # Both `network = "sepolia"` and `sepolia = true` give `--network sepolia` once.
  lighthouseNetworkOnce =
    name:
    let
      s = execStart "lighthouse-beacon-${name}";
    in
    count "--network" s == 1 && lib.hasInfix "--network \\\n  sepolia" s;

  # ethereum.nix doesn't build lighthouse for aarch64-linux. The default must
  # fail with the module's `throw` (catchable by tryEval), not with an
  # uncatchable "attribute 'lighthouse' missing".
  armHasLighthouse = flake.packages.aarch64-linux ? lighthouse;
  arm = eval "aarch64-linux" [
    flake.nixosModules.lighthouse-beacon
    { services.ethereum.lighthouse-beacon.sepolia.enable = true; }
  ];
  armDefault = builtins.tryEval arm.services.ethereum.lighthouse-beacon.sepolia.package.outPath;
in
assert lib.assertMsg gethDefault "geth ExecStart does not use ethereum.nix's geth";
assert lib.assertMsg (lighthouseNetworkOnce "explicit")
  "lighthouse-beacon with network = \"sepolia\" must pass --network sepolia exactly once";
assert lib.assertMsg (lighthouseNetworkOnce "shorthand")
  "lighthouse-beacon with sepolia = true must pass --network sepolia exactly once";
assert lib.assertMsg (
  !armHasLighthouse
) "lighthouse is now built for aarch64-linux; pick another package for the missing-package check";
assert lib.assertMsg (
  !armDefault.success
) "package default for a system ethereum.nix doesn't build should throw";
pkgs.runCommand "nixos-modules-eval" { } "touch $out"
