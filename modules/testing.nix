{
  self,
  inputs,
  ...
}: {
  perSystem = {
    lib,
    config,
    system,
    ...
  }: let
    # create a custom nixpkgs with our flake packages available
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        self.overlays.default
      ];
    };
  in {
    ########################################
    ## Interface
    ########################################
    options.testing.checks = with lib;
      mkOption {
        type = types.attrsOf types.package;
        default = {};
      };

    ########################################
    ## Implementation
    ########################################
    config.testing.checks = with lib; let
      # import the testing framework
      nixos-lib = import (pkgs.path + "/nixos/lib") {};

      # traverse the filesystem and capture any files with `.test.nix` suffix
      eachTest =
        filterAttrs
        (_: (hasSuffix ".test.nix"))
        (fs.flattenTree {
          tree = fs.rakeLeaves ./.;
          separator = "-";
        });

      # examine the `systems` attribute of each test, filtering out any that do not support the current system
      eachTestForSystem = with lib;
        filterAttrs
        (_: v: elem system v.systems)
        (mapAttrs (_: import) eachTest);
    in
      mapAttrs'
      (name: test:
        nameValuePair "testing-${removeSuffix ".test" name}"
        (nixos-lib.runTest {
          hostPkgs = pkgs;

          # speed up evaluation by skipping docs
          defaults.documentation.enable = lib.mkDefault false;

          # make self available in test modules and our custom pkgs
          node.specialArgs = {inherit self pkgs;};

          # import all of our flake nixos modules by default
          defaults.imports = [
            self.nixosModules.default
          ];

          # import the test module
          imports = [test.module];
        })
        .config
        .result)
      eachTestForSystem;

    ########################################
    ## Commands
    ########################################
    config.devshells.default.commands = [
      {
        name = "tests";
        category = "Testing";
        help = "Build and run a test";
        command = ''
          Help() {
               # Display Help
               echo "  Build and run a test"
               echo
               echo "  Usage:"
               echo "    , test <name>"
               echo "    , test <name> --interactive"
               echo "    , test -s <system> <name>"
               echo
               echo "  Arguments:"
               echo "    <name> If a test package is called 'testing-nethermind-basic' then <name> should be 'nethermind-basic'."
               echo
               echo "  Options:"
               echo "    -h --help          Show this screen."
               echo "    -s --system        Specify the target platform [default: x84_64-linux]."
               echo "    -i --interactive   Run the test interactively."
               echo
          }

          ARGS=$(getopt -o ihs: --long interactive,help,system: -n ', test' -- "$@")
          eval set -- "$ARGS"

          SYSTEM="x86_64-linux"
          DRIVER_ARGS=()

          while [ $# -gt 0 ]; do
            case "$1" in
                -i | --interactive) DRIVER_ARGS+=("--interactive"); shift;;
                -s | --system) SYSTEM="$2"; shift 2;;
                -h | --help) Help; exit 0;;
                -- ) shift; break;;
                * ) break;;
            esac
          done

          if [ $# -eq 0 ]; then
            # No test name has been provided
            Help
            exit 1
          fi

          NAME="$1"
          shift

          # build the test driver
          nix build ".#checks.$SYSTEM.testing-$NAME.driver"

          # run the test driver, passing any remaining arguments
          set -x
          ./result/bin/nixos-test-driver "''${DRIVER_ARGS[@]}"
        '';
      }
    ];
  };
}
