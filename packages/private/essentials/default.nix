{
  python311Packages,
  fetchFromGitHub,
  lib,
}:
python311Packages.buildPythonPackage rec {
  pname = "essentials";
  version = "1.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Neoteroi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-WMHjBVkeSoQ4Naj1U7Bg9j2hcoErH1dx00BPKiom9T4=";
  };

  buildInputs = with python311Packages; [
    setuptools
  ];

  nativeCheckInputs = with python311Packages; [
    pytestCheckHook
    pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "essentials"
  ];

  meta = with lib; {
    homepage = "https://github.com/Neoteroi/essentials";
    description = "General purpose classes and functions";
    changelog = "https://github.com/Neoteroi/essentials/releases/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
  };
}
