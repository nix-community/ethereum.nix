{ pkgs, ... }:
pkgs.callPackage ./package.nix {
  superchainConfigsHook = pkgs.callPackage ../../lib/optimism/superchain-configs-hook.nix { };
}
