{
  essentials,
  fetchFromGitHub,
  python3Packages,
}:
with python3Packages;
  buildPythonPackage rec {
    pname = "essentials-openapi";
    version = "1.0.7";

    format = "pyproject";

    src = fetchFromGitHub {
      owner = "Neoteroi";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-j0vEMNXZ9TrcFx8iIyTFQIwF49LEincLmnAt+qodYmA=";
    };

    nativeBuildInputs = [
      hatchling
      pyyaml
    ];

    propagatedBuildInputs = [
      essentials
    ];

    doCheck = false;

    pythonImportsCheck = ["openapidocs"];
  }
