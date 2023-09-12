{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    checks = let
      devour-flake = pkgs.callPackage inputs.devour-flake {};
    in
      {
        nix-build-all = pkgs.writeShellApplication {
          name = "nix-build-all";
          runtimeInputs = [
            pkgs.nix
            devour-flake
          ];
          text = ''
            # Make sure that flake.lock is sync
            nix flake lock --no-update-lock-file

            # Do a full nix build (all outputs)
            devour-flake . "$@"
          '';
        };
      }
      # mix in tests
      // config.testing.checks;

    devshells.default.commands = [
      {
        category = "Tools";
        name = "check";
        help = "Checks the source tree";
        command = "nix flake check";
      }
    ];
  };
}
