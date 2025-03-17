{
  autoPatchelfHook,
  fetchurl,
  stdenv,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "staking-deposit-cli";
  version = "2.7.0";

  src = fetchurl {
    url = "https://github.com/ethereum/staking-deposit-cli/releases/download/v${version}/staking_deposit-cli-fdab65d-linux-amd64.tar.gz";
    hash = "sha256-rDFRhD1oHJKudVZ6iPvg4EDVPCE2jMHtGow9n7KfKjo=";
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
