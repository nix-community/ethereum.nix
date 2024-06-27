{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  moreutils,
  nodePackages,
  nodejs,
  cacert,
}:
stdenv.mkDerivation rec {
  pname = "hardhat";
  version = "dfd91d254362a3f5a0a2c940398e8af7d677f876";

  src = fetchFromGitHub {
    owner = "NomicFoundation";
    repo = "hardhat";
    rev = version;
    #rev = "refs/tags/hardhat@${version}";
    hash = "sha256-whyUTV65FN4xg437Ardq/PiDoyQoLBULwU49ttTjMlM=";
  };

  pnpmDeps = stdenvNoCC.mkDerivation {
    pname = "${pname}-pnpm-deps";
    inherit src version;

    nativeBuildInputs = [
      jq
      moreutils
      nodePackages.pnpm
      cacert
    ];

    installPhase = ''
      runHook preInstall
      export HOME=$(mktemp -d)
      pnpm config set store-dir $out
      # pnpm is going to warn us about using --force
      # --force allows us to fetch all dependencies including
      # ones that aren't meant for our host platform
      pnpm install --frozen-lockfile --ignore-script --force
      runHook postInstall
    '';

    fixupPhase = ''
      runHook preFixup
      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done
      runHook postFixup
    '';

    dontConfigure = true;
    dontBuild = true;
    outputHashMode = "recursive";
    outputHash = "sha256-vxgHbML6KV80iIBSBc3deMgw0JMWODjAqMtGN05BS6k=";
  };

  nativeBuildInputs = [
    nodePackages.pnpm
    nodejs
  ];

  preBuild = ''
    export HOME=$(mktemp -d)

    pnpm config set store-dir ${pnpmDeps}
    pnpm install --offline --frozen-lockfile --ignore-script
    patchShebangs node_modules/{*,.*}
  '';

  postBuild = ''
    pnpm build
  '';

  checkPhase = ''
    pnpm run test --run
  '';

  installPhase = ''
    runHook preInstall

    find . -name "*dist*"

    # TODO

    runHook postInstall
  '';

  passthru = {
    inherit pnpmDeps;
  };

  meta = with lib; {
    description = "A development environment to compile, deploy, test, and debug your Ethereum software.";
    homepage = "https://hardhat.org";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
  };
}
