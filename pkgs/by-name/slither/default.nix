{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "slither";
  version = "0.11.3";
  format = "pyproject";

  disabled = python3.pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-HgPQPyxDvKrmqGiHjiVGxEguYUcaNYwK1gZoMMkQWhM=";
  };

  nativeBuildInputs = with python3.pkgs; [
    eth-abi
    eth-typing
    eth-utils
    pycryptodome
    web3
  ];

  propagatedBuildInputs = with python3.pkgs; [
    crytic-compile
    packaging
    prettytable
    web3
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
