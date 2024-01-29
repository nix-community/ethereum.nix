{
  _essentials,
  fetchFromGitHub,
  lib,
  python311Packages,
}:
python311Packages.buildPythonPackage rec {
  pname = "essentials-openapi";
  version = "1.0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Neoteroi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-j0vEMNXZ9TrcFx8iIyTFQIwF49LEincLmnAt+qodYmA=";
  };

  nativeCheckInputs = with python311Packages; [
    flask
    hatchling
    pydantic
    pytestCheckHook
    pythonImportsCheckHook
    pyyaml
  ];

  propagatedBuildInputs = with python311Packages; [
    click
    _essentials
    httpx
    jinja2
    markupsafe
    rich
    setuptools
  ];

  pythonImportsCheck = [
    "openapidocs"
  ];

  meta = with lib; {
    homepage = "https://github.com/Neoteroi/essentials-openapi";
    description = "Functions to handle OpenAPI Documentation";
    changelog = "https://github.com/Neoteroi/essentials-openapi/releases/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
  };
}
