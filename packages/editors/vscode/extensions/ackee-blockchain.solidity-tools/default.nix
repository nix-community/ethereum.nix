{
  lib,
  vscode-utils,
}: let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "tools-for-solidity";
      publisher = "AckeeBlockchain";
      version = "1.8.0";
      sha256 = "sha256-fVDldD4RJ5RocbBIT3VE1uWiv1Oc88g1cp5EkSvPphU=";
    };

    meta = {
      description = "VS Code plugin implementing a language server for Solidity";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
    };
  }
