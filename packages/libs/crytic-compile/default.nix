{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "crytic-compile";
  version = "0.3.4";
  format = "setuptools";

  disabled = python3.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = "crytic-compile";
    rev = "refs/tags/${version}";
    hash = "sha256-CeoACtgvMweDbIvYguK2Ca+iTBFONWcE2b0qUkBbQSU=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    cbor2
    pycryptodome
    setuptools
    solc-select
  ];

  # Test require network access
  doCheck = false;

  # required for import check to work
  # PermissionError: [Errno 13] Permission denied: '/homeless-shelter'
  env.HOME = "/tmp";
  pythonImportsCheck = [
    "crytic_compile"
  ];

  meta = with lib; {
    description = "Abstraction layer for smart contract build systems";
    homepage = "https://github.com/crytic/crytic-compile";
    license = licenses.agpl3Plus;
    platforms = ["x86_64-linux"];
  };
}
