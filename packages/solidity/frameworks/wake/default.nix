{
  poetry2nix,
  lib,
}: let
  src = builtins.fetchTarball {
    url = "https://github.com/Ackee-Blockchain/wake/archive/refs/tags/v4.3.0.tar.gz";
    sha256 = "sha256-j//h63F8j6q0LL56EQoy9RcPMVfhmXp+VyDEJOqHfLg=";
  };
in
  poetry2nix.mkPoetryApplication {
    projectDir = src;

    # TODO: For now we install the basic version, including the *
    # incurs in some CVE security exceptions
    extras = [];

    overrides = poetry2nix.overrides.withDefaults (_self: super: {
      abch-tree-sitter-solidity =
        super.abch-tree-sitter-solidity.overridePythonAttrs
        (old: {buildInputs = (old.buildInputs or []) ++ [super.setuptools];});
      abch-tree-sitter =
        super.abch-tree-sitter.overridePythonAttrs
        (old: {buildInputs = (old.buildInputs or []) ++ [super.setuptools];});
      pywin32 = null;
    });

    meta = with lib; {
      homepage = "https://github.com/Ackee-Blockchain/wake";
      description = "Wake is a Python-based Solidity development and testing framework with built-in vulnerability detectors";
      changelog = "https://github.com/Ackee-Blockchain/wake/releases/tag/v${version}";
      mainProgram = "wake";
      license = licenses.mit;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      maintainers = with maintainers; [aldoborrero];
    };
  }
