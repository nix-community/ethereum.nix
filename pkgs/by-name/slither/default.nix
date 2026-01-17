{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3,
  makeWrapper,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "slither";
  version = "0.11.5";
  pyproject = true;

  disabled = python3.pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-sy1vE9XniwyvvZRFnnKhPfmYh2auHHcMel9sZx2YK3c=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3.pkgs.setuptools-scm
    python3.pkgs.hatchling
  ];

  propagatedBuildInputs = with python3.pkgs; [
    crytic-compile
    importlib-metadata
    packaging
    prettytable
    web3
  ];

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

  pythonImportsCheck = ["slither"];

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "Static Analyzer for Solidity";
    homepage = "https://github.com/crytic/slither";
    license = licenses.agpl3Only;
    platforms = ["x86_64-linux"];
  };
}
