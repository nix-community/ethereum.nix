{
  fetchurl,
  gcc-unwrapped,
  lib,
  patchelf,
  stdenv,
  writeText,
}:
let
  # Patch a solc binary for Nix
  patchSolc =
    { name, src }:
    stdenv.mkDerivation {
      inherit name src;
      dontUnpack = true;
      nativeBuildInputs = [ patchelf ];
      buildInputs = [
        gcc-unwrapped.lib
        stdenv.cc.cc.lib
      ];
      installPhase = ''
        install -m 755 $src $out
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${
            lib.makeLibraryPath [
              gcc-unwrapped.lib
              stdenv.cc.cc.lib
            ]
          }" $out
      '';
    };
in
{
  solc_0_7_6 = patchSolc {
    name = "solc-0.7.6";
    src = fetchurl {
      url = "https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v0.7.6+commit.7338295f";
      hash = "sha256-vWnqhUJ78vTadMtCatlR3Xjbnf3QHXkSCOzMLUlYprs=";
    };
  };

  solc_0_8_9 = patchSolc {
    name = "solc-0.8.9";
    src = fetchurl {
      url = "https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v0.8.9+commit.e5eed63a";
      hash = "sha256-+FHxH603SWuquvjWy1wFfKDZdU/dt6NRq1gNf9coy5Q=";
    };
  };

  solc_0_8_17 = patchSolc {
    name = "solc-0.8.17";
    src = fetchurl {
      url = "https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v0.8.17+commit.8df45f5f";
      hash = "sha256-mfIHC3dulxTx92xDwinPmbiXipKTjujSNkxt4RwaA9Q=";
    };
  };

  solc_0_8_24 = patchSolc {
    name = "solc-0.8.24";
    src = fetchurl {
      url = "https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v0.8.24+commit.e11b9ed9";
      hash = "sha256-+wOimlF0UrnxK89FnvN9ClQ3Zbs7vJEecKh9ajfDDV8=";
    };
  };

  # Hardhat compiler list metadata
  hardhatCompilerList = writeText "list.json" (
    builtins.toJSON {
      builds = [
        {
          path = "solc-linux-amd64-v0.7.6+commit.7338295f";
          version = "0.7.6";
          build = "commit.7338295f";
          longVersion = "0.7.6+commit.7338295f";
          keccak256 = "0x34b08e7dd290c762f21ebe591407e498a43d79ce4530f84340d7b7e5719e62e5";
          sha256 = "0x63d16cf69dd4d94edc75c2a49af95f0f4d5e99bb4e3e4a890cc93acfa25395dc";
          urls = [ "bzzr://e77d78cbf4e3dc438d21f7fb46c01ca5a532c54d64b893e9d6ee16d232f26a68" ];
        }
        {
          path = "solc-linux-amd64-v0.8.9+commit.e5eed63a";
          version = "0.8.9";
          build = "commit.e5eed63a";
          longVersion = "0.8.9+commit.e5eed63a";
          keccak256 = "0xc3a70946c825ecd5d7ce2db1ff2e9a608f1319e8912cc10bd1be9d171617066e";
          sha256 = "0xf851f11fad37496baabaf8d6cb5c057ca0d9754fddb7a351ab580d7fd728cb94";
          urls = [ ];
        }
        {
          path = "solc-linux-amd64-v0.8.17+commit.8df45f5f";
          version = "0.8.17";
          build = "commit.8df45f5f";
          longVersion = "0.8.17+commit.8df45f5f";
          keccak256 = "0xc35c1d26fd3e3c53cff5108eb4754fc6c644a69f9f80899a8994c648e8211e67";
          sha256 = "0xd9bc8ddc536a97889e1fa02e55f6a6073af25c0fbb4caa81a21048987dd8a14e";
          urls = [ "bzzr://e77d78cbf4e3dc438d21f7fb46c01ca5a532c54d64b893e9d6ee16d232f26a68" ];
        }
        {
          path = "solc-linux-amd64-v0.8.24+commit.e11b9ed9";
          version = "0.8.24";
          build = "commit.e11b9ed9";
          longVersion = "0.8.24+commit.e11b9ed9";
          keccak256 = "0x";
          sha256 = "0x";
          urls = [ ];
        }
      ];
      releases = {
        "0.7.6" = "solc-linux-amd64-v0.7.6+commit.7338295f";
        "0.8.9" = "solc-linux-amd64-v0.8.9+commit.e5eed63a";
        "0.8.17" = "solc-linux-amd64-v0.8.17+commit.8df45f5f";
        "0.8.24" = "solc-linux-amd64-v0.8.24+commit.e11b9ed9";
      };
      latestRelease = "0.8.24";
    }
  );
}
