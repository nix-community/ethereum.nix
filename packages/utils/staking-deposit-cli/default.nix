{
  autoPatchelfHook,
  fetchurl,
  stdenv,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "staking-deposit-cli";
  version = "2.6.0";

  src = fetchurl {
    url = "https://github.com/ethereum/staking-deposit-cli/releases/download/v${version}/staking_deposit-cli-33cdafe-linux-amd64.tar.gz";
    hash = "sha256-SHug2OJwD6Na3WzvajH6mkHNpDM9n4E2WG2DHTGrd6M=";
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
