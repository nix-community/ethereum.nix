{
  lib,
  buildGo121Module,
  fetchFromGitHub,
  mockgen,
}:
buildGo121Module rec {
  pname = "eigenlayer-cli";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "NethermindEth";
    repo = "eigenlayer";
    rev = "v${version}";
    hash = "sha256-VO56mMkUVeZN+YJ/cxPyZQ5dGvVDirslH4jhV5hpufQ=";
  };

  vendorHash = "sha256-DDGMprfryWj9Td4PX/j5Fsjm+bGGiDgnCXmm2IhRSMo=";

  overrideModAttrs = oldAttrs: {
    nativeBuildInputs = [mockgen] ++ oldAttrs.nativeBuildInputs;

    # can't pass the go-module tests related to mocks without that
    preBuild = ''
      go generate ./...
    '';
  };

  ldflags = ["-s" "-w"];
  subPackages = ["cmd/eigenlayer"];

  # Can't pass tests with mockgen and go generate ./...
  # preBuild = ''
  #   go generate ./...
  # '';
  doCheck = false;

  postInstall = ''
    mv $out/bin/eigenlayer $out/bin/eigenlayer-cli
  '';

  meta = with lib; {
    description = "Utility manages core operator functionalities like local key management, operator registration and updates";
    homepage = "https://www.eigenlayer.xyz/";
    license = licenses.bsl11;
    mainProgram = "eigenlayer-cli";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
