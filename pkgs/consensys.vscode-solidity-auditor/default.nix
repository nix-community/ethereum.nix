{
  lib,
  vscode-utils,
}: let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "solidity-visual-auditor";
      publisher = "tintinweb";
      version = "0.1.5";
      sha256 = "sha256-laCH+jeh8/2XFUwHOyAjjfXhoLpEWWoHA0sTFdsjJiY=";
    };

    meta = {
      description = "Solidity language support and visual security auditor for Visual Studio Code";
      license = lib.licenses.gpl3;
      platforms = ["x86_64-linux"];
    };
  }
