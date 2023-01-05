{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: {
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      package = pkgs.treefmt;

      programs = {
        alejandra.enable = true;
        prettier.enable = true;
      };
    };

    mission-control.scripts = {
      fmt = {
        category = "Tools";
        description = "Format the source tree";
        exec = "${lib.getExe config.treefmt.build.wrapper}";
      };
    };

    formatter = config.treefmt.build.wrapper;
  };
}
