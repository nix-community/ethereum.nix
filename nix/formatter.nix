{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      package = pkgs.treefmt;
      flakeFormatter = true;
      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        prettier.enable = true;
        mdformat.enable = true;
      };
      settings.formatter.prettier.excludes = ["*.md"];
    };

    devshells.default.commands = [
      {
        category = "Tools";
        name = "fmt";
        help = "Format the source tree";
        command = "nix fmt";
      }
    ];
  };
}
