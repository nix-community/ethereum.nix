{
  fetchFromGitHub,
  poetry2nix,
  zlib,
  lib,
}:
poetry2nix.mkPoetryApplication {
  projectDir = fetchFromGitHub {
    owner = "Ackee-Blockchain";
    repo = "woke";
    rev = "v3.6.1";
    sha256 = "sha256-dG2sPAUdl4TVeXe2c7TmbtRnJmqG65oqQYGV8ghc3yI=";
  };

  # TODO: For now we install the basic version, including the *
  # incurs in some CVE security exceptions
  extras = [];

  overrides = poetry2nix.overrides.withDefaults (_self: super: {
    eth-hash = super.eth-hash.overridePythonAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [super.setuptools];
    });
    abch-tree-sitter-solidity =
      super.abch-tree-sitter-solidity.overridePythonAttrs
      (
        old: {
          buildInputs = (old.buildInputs or []) ++ [super.setuptools];
        }
      );
    abch-tree-sitter =
      super.abch-tree-sitter.overridePythonAttrs
      (
        old: {
          buildInputs = (old.buildInputs or []) ++ [super.setuptools];
        }
      );
    rich-click =
      super.rich-click.overridePythonAttrs
      (
        old: {
          buildInputs = (old.buildInputs or []) ++ [super.setuptools];
        }
      );
    griffe =
      super.griffe.overridePythonAttrs
      (
        old: {
          buildInputs = (old.buildInputs or []) ++ [super.pdm-backend];
        }
      );
    pillow =
      super.pillow.overridePythonAttrs
      (
        _old: {
          nativeBuildInputs = [
            zlib
          ];
        }
      );
    pywin32 = null;
  });

  meta = with lib; {
    homepage = "https://github.com/Ackee-Blockchain/wake";
    description = "Wake is a Python-based Solidity development and testing framework with built-in vulnerability detectors";
    changelog = "https://github.com/Ackee-Blockchain/wake/releases/tag/v${version}";
    mainProgram = "woke";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = with maintainers; [aldoborrero];
  };
}
