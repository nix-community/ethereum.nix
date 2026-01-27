{
  autoPatchelfHook,
  fetchurl,
  nix-update-script,
  stdenv,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "staking-deposit-cli";
  version = "2.8.0";

  src = fetchurl {
    url = "https://github.com/ethereum/staking-deposit-cli/releases/download/v${version}/staking_deposit-cli-948d3fc-linux-amd64.tar.gz";
    hash = "sha256-7wISUqvSWR7201WPsyWLNfR4wgMz8t/0oXzHm1c8OHk=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ zlib ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv ./deposit $out/bin/deposit

    runHook postInstall
  '';

  passthru = {
    category = "Staking";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Secure key generation for deposits";
    homepage = "https://github.com/ethereum/staking-deposit-cli";
    mainProgram = "deposit";
    platforms = [ "x86_64-linux" ];
  };
}
