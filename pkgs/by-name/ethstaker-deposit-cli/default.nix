{
  autoPatchelfHook,
  fetchurl,
  nix-update-script,
  stdenv,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "staking-deposit-cli";
  version = "1.2.2-unstable-2025-10-02";

  src = fetchurl {
    url = "https://github.com/ethstaker/ethstaker-deposit-cli/releases/download/v1.2.2/ethstaker_deposit-cli-b13dcb9-linux-amd64.tar.gz";
    hash = "sha256-BK8/T9L9zPSuBgq95HY3YioxEU2fLlPmJyKmlKTVsgY=";
  };

  nativeBuildInputs = [autoPatchelfHook];

  buildInputs = [zlib];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv ./deposit $out/bin/deposit

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Secure key generation for deposits (ethstaker fork)";
    homepage = "https://github.com/ethstaker/ethstaker-deposit-cli/";
    mainProgram = "deposit";
    platforms = ["x86_64-linux"];
  };
}
