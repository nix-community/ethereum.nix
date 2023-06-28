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
    mdformat-footnote = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-footnote";
      version = "0.1.1";

      format = "flit";

      src = pkgs.fetchFromGitHub {
        owner = "executablebooks";
        repo = pname;
        rev = "refs/tags/v${version}";
        hash = "sha256-DUCBWcmB5i6/HkqxjlU3aTRO7i0n2sj+e/doKB8ffeo=";
      };

      buildInputs = with pkgs.python3Packages; [
        mdformat
        mdit-py-plugins
      ];
    };

    # TODO: Upstream this to nixpkgs
    mdformat-frontmatter = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-frontmatter";
      version = "2.0.1";

      format = "flit";

      src = pkgs.fetchFromGitHub {
        owner = "butler54";
        repo = pname;
        rev = "refs/tags/v${version}";
        hash = "sha256-PhT5whtvvcYSs5gHQEsIvV1evhx7jR+3DWFMHrF0uMw=";
      };

      buildInputs = with pkgs.python3Packages; [
        mdformat
        mdit-py-plugins
      ];

      propagatedBuildInputs = with pkgs.python3Packages; [ruamel-yaml];
    };

    # TODO: Upstream this to nixpkgs
    mdformat-simple-breaks = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-simple-breaks";
      version = "0.0.1";

      format = "flit";

      src = pkgs.fetchFromGitHub {
        owner = "csala";
        repo = pname;
        rev = "refs/tags/v${version}";
        hash = "sha256-4lJHB4r9lI2uGJ/BmFFc92sumTRKBBwiRmGBdQkzfd0=";
      };

      buildInputs = with pkgs.python3Packages; [
        mdformat
      ];
    };

    mdformat-toc = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-toc";
      version = "0.3.0";

      format = "pyproject";

      src = pkgs.fetchFromGitHub {
        owner = "hukkin";
        repo = pname;
        rev = "refs/tags/${version}";
        hash = "sha256-3EX6kGez408tEYiR9VSvi3GTrb4ds+HJwpFflv77nkg=";
      };

      nativeBuildInputs = with pkgs.python3Packages; [
        poetry-core
      ];

      buildInputs = with pkgs.python3Packages; [
        mdformat
      ];
    };

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
    };

    # TODO: Upstream this to nixpkgs
    mdformat-gfm = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-gfm";
      version = "0.3.5";

      format = "pyproject";

      src = pkgs.fetchFromGitHub {
        owner = "hukkin";
        repo = pname;
        rev = "refs/tags/${version}";
        hash = "sha256-7sIa50jCN+M36Y0C05QaAL+TVwLzKxJ0gzpZI1YQFxg=";
      };

      nativeBuildInputs = with pkgs.python3Packages; [
        poetry-core
      ];

      buildInputs = with pkgs.python3Packages; [
        mdformat
        markdown-it-py
        mdit-py-plugins
      ];

      propagatedBuildInputs = with pkgs.python3Packages; [
        mdformat-tables
        linkify-it-py
      ];
    };

    # TODO: Upstream this to nixpkgs
    mdformat-admon = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-admon";
      version = "1.0.2";

      format = "flit";

      src = pkgs.fetchFromGitHub {
        owner = "KyleKing";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-33Q3Re/axnoOHZ9XYA32mmK+efsSelJXW8sD7C1M/jU=";
      };

      buildInputs = with pkgs.python3Packages; [mdformat];

      propagatedBuildInputs = with pkgs.python3Packages; [
        (mdit-py-plugins.overridePythonAttrs (_prev: rec {
          version = "0.4.0";
          doCheck = false;
          src = pkgs.fetchFromGitHub {
            owner = "executablebooks";
            repo = "mdit-py-plugins";
            rev = "refs/tags/v${version}";
            hash = "sha256-YBJu0vIOD747DrJLcqiZMHq34+gHdXeGLCw1OxxzIJ0=";
          };
        }))
      ];
    };

    # TODO: Upstream this to nixpkgs
    mdformat-mkdocs = pkgs.python3Packages.buildPythonPackage rec {
      pname = "mdformat-mkdocs";
      version = "1.0.2";

      format = "flit";

      src = pkgs.fetchFromGitHub {
        owner = "KyleKing";
        repo = pname;
        rev = "refs/tags/v${version}";
        hash = "sha256-H+wqgcXNrdrZ5aQvZ7XM8YpBpVZM6pFtsANC00UZ0jM=";
      };

      buildInputs = with pkgs.python3Packages; [
        mdformat
        mdformat-gfm
        mdit-py-plugins
      ];
    };

    mdformat-custom = pkgs.python3Packages.mdformat.overridePythonAttrs (prev: rec {
      propagatedBuildInputs =
        prev.propagatedBuildInputs
        ++ [
          mdformat-admon
          mdformat-footnote
          mdformat-frontmatter
          mdformat-gfm
          mdformat-mkdocs
          mdformat-simple-breaks
          mdformat-toc
        ];
      disabledTests = [
        "test_config_file.py"
        "test_for_profiler.py"
        "test_plugins.py"
        "test_style.py"
      ];
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

    devshells.default.packages = [mdformat-custom];

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
