{
  lib,
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    mkDream2nixPackage = args: inputs.dream2nix.lib.makeFlakeOutputs (
      {
        systems = [system];
        config.projectRoot = self;
      }
      // args
    );

    lodestar = mkDream2nixPackage rec {
      source = builtins.fetchTarball {
        url = "https://github.com/ChainSafe/lodestar/tarball/v1.7.2";
        sha256 = "sha256-ctJzQbmF71msj5TBj0RBoLdfsqmuh2EbkT3ZVKewRE4=";
      };
      projects.lodestar = {
        name = "lodestar";
        subsystem = "nodejs";
        translator = "yarn-lock";
        builder = "granular-nodejs";
        subsystemInfo = {
          nodejs = "18";
          noDev = false;
          workspacesInheritParentDeps = true;
          workspaces = map
            (dir: "packages/${dir}")
            (builtins.attrNames (builtins.readDir ("${source}/packages")));
        };
      };
      packageOverrides = {
        nx.no-postinstall.buildScript = "true";

        # create a fake `yarn` allowing lerna to execute `yarn run build`
        lodestar.fix.preBuild = ''
          mkdir $TMPDIR/bin
          echo 'npm "$@"' > $TMPDIR/bin/yarn
          chmod +x $TMPDIR/bin/yarn
          export PATH="$PATH:$TMPDIR/bin"
        '';

        # prevent dream2nix from running electron-rebuild on top-level
        lodestar.fix.electronHeaders = null;
        # prevent dream2nix from running electron-rebuild on workspace members
        "^@lodestar/.*".fix.electronHeaders = null;

        # node-gyp fails. Just disable install.
        gc-stats.disable-install.buildScript = "true";

        # run build for all workspace members
        "^@lodestar/.*".run-build.runBuild = true;

        # fix tsconfig `extends`
        "^@lodestar/.*".run-build.preBuild = ''
          substituteInPlace tsconfig.build.json \
            --replace "../../tsconfig.build.json" "${source}/tsconfig.build.json"
        '';
      };
    };
  in {
    packages = lodestar.packages.${system};
  };
}
