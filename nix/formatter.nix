{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: let
    # TODO: Upstream this to nixpkgs
    mdformat-tables = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-tables";
      version = "0.4.1";

      format = "flit";

      src = pkgs.fetchFromGitHub {
        owner = "executablebooks";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-Q61GmaRxjxJh9GjyR8QCZOH0njFUtAWihZ9lFQJ2nQQ=";
      };

      buildInputs = with pkgs.python3Packages; [
        mdformat
      ];

      doCheck = false;
    };

    # TODO: Upstream this to nixpkgs
    mdformat-gfm = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-gfm";
      version = "0.3.5";

      format = "other";

      src = pkgs.fetchFromGitHub {
        owner = "hukkin";
        repo = pname;
        rev = "refs/tags/${version}";
        hash = "sha256-7sIa50jCN+M36Y0C05QaAL+TVwLzKxJ0gzpZI1YQFxg=";
      };

      buildInputs = with pkgs.python3Packages; [
        mdformat
        markdown-it-py
        mdit-py-plugins
        mdformat-tables
      ];

      doCheck = false;
    };

    # TODO: Upstream this to nixpkgs
    mdformat-admon = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-admon";
      version = "1.0.2";

      format = "other";

      src = pkgs.fetchFromGitHub {
        owner = "KyleKing";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-33Q3Re/axnoOHZ9XYA32mmK+efsSelJXW8sD7C1M/jU=";
      };

      buildInputs = with pkgs.python3Packages; [
        mdformat
        mdit-py-plugins
      ];

      doCheck = false;
    };

    mdformat-custom = pkgs.python3Packages.mdformat.overrideAttrs (_final: prev: {
      propagatedBuildInputs = prev.propagatedBuildInputs ++ [mdformat-gfm mdformat-admon];
    });
  in {
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      package = pkgs.treefmt;
      flakeFormatter = true;
      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        prettier.enable = true;
        mdformat.enable = true;
        mdformat.package = mdformat-custom;
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
