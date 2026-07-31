{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3,
  makeWrapper,
}:
let
  # slither 0.11.6 requires crytic-compile >=0.4.2, newer than the version in
  # nixpkgs. Override it here until nixpkgs catches up. 0.4.x switched to the
  # uv_build backend and dropped the toml/setuptools dependencies.
  crytic-compile = python3.pkgs.crytic-compile.overridePythonAttrs (_old: {
    version = "0.4.2";
    src = fetchFromGitHub {
      owner = "crytic";
      repo = "crytic-compile";
      tag = "0.4.2";
      hash = "sha256-0zpalWsyFzsgSrmTi9WyHfRcRympv2WoJNEtzpWXmGk=";
    };
    format = null;
    pyproject = true;
    build-system = [ python3.pkgs.uv-build ];
    # nixpkgs ships uv-build 0.11, but the pyproject pins uv_build<0.10.
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'uv_build>=0.6,<0.10' 'uv_build>=0.6'
    '';
    propagatedBuildInputs = with python3.pkgs; [
      cbor2
      pycryptodome
      solc-select
    ];
  });
in
python3.pkgs.buildPythonPackage rec {
  # Distribution name is slither-analyzer; the repo is just "slither".
  pname = "slither-analyzer";
  version = "0.11.6";
  pyproject = true;

  disabled = python3.pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = "slither";
    rev = "refs/tags/${version}";
    hash = "sha256-Uo6mwJ9keG3tUMvh4v0MEJWJ1WStGxvzzh3PmHy/gCs=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3.pkgs.setuptools-scm
    python3.pkgs.hatchling
  ];

  propagatedBuildInputs = [
    crytic-compile
  ]
  ++ (with python3.pkgs; [
    importlib-metadata
    packaging
    prettytable
    web3
  ]);

  pythonRelaxDeps = [
    "web3"
    "eth-account"
    "coincurve"
  ];

  # required for import check to work
  # PermissionError: [Errno 13] Permission denied: '/homeless-shelter'
  env.HOME = "/tmp";
  # Test require network access
  doCheck = false;

  pythonImportsCheck = [ "slither" ];

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Static Analyzer for Solidity";
    homepage = "https://github.com/crytic/slither";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
