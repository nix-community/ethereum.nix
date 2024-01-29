{
  _essentials-openapi,
  fetchFromGitHub,
  lib,
  python311Packages,
}:
python311Packages.buildPythonPackage rec {
  pname = "mkdocs-plugins";
  version = "1.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Neoteroi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-C/HOqti8s/+V9scbS/Ch0i4sSFvRMF/K5+b6qzgTFSc=";
  };

  buildInputs = with python311Packages; [
    setuptools
    hatchling
  ];

  nativeCheckInputs = with python311Packages; [
    pytestCheckHook
    pythonImportsCheckHook
    flask
  ];

  propagatedBuildInputs = with python311Packages; [
    _essentials-openapi
    click
    jinja2
    httpx
    mkdocs
    rich
  ];

  disabledTests = [
    "test_contribs" # checks against it's own git repository
  ];

  pythonImportsCheck = [
    "neoteroi.mkdocs"
  ];

  meta = with lib; {
    homepage = "https://github.com/Neoteroi/mkdocs-plugins";
    description = "Plugins for MkDocs";
    changelog = "https://github.com/Neoteroi/mkdocs-plugins/releases/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
  };
}
