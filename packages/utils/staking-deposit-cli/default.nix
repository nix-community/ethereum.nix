{
  autoPatchelfHook,
  fetchurl,
  stdenv,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "staking-deposit-cli";
  version = "2.5.0";

  src = fetchurl {
    url = "https://github.com/ethereum/staking-deposit-cli/releases/download/v${version}/staking_deposit-cli-d7b5304-linux-amd64.tar.gz";
    hash = "sha256-P1GFnXitR6PiWEcPWlyvA9Ge0dQwfVFzJbe7j2/N5u8=";
  };

  nativeBuildInputs = [autoPatchelfHook];

  buildInputs = [zlib];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv ./deposit $out/bin/deposit

    runHook postInstall
  '';

  meta = {
    description = "Secure key generation for deposits";
    homepage = "https://github.com/ethereum/staking-deposit-cli";
    mainProgram = "deposit";
    platforms = ["x86_64-linux"];
  };
}
