{ pkgs }:
let
  # py-evm does not support python 3.14 (the nixpkgs default), so pin 3.12.
  # The 3.12 package set is not built by Hydra and anyio's TLS tests fail there
  # ("server_hostname can only be specified in client mode"); skip them.
  python3 = pkgs.python312.override {
    packageOverrides = _final: prev: {
      anyio = prev.anyio.overridePythonAttrs { doCheck = false; };
    };
  };
in
pkgs.callPackage ./package.nix { inherit python3; }
