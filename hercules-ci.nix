{
  inputs,
  lib,
  ...
}: {
  # configuration for the Hercules CI flake update effect
  # https://flake.parts/options/hercules-ci-effects.html#opt-hercules-ci.flake-update.enable
  hercules-ci.flake-update = {
    enable = true;
    # runs every day at midnight UTC
    when.hour = 0;
  };

  # disable the default job since buildbot already builds everything
  herculesCI.onPush.default.outputs = lib.mkForce {
    # use hello as a dummy output to get the checkmark
    inherit (inputs.nixpkgs-unstable.legacyPackages.x86_64-linux) hello;
  };
}
