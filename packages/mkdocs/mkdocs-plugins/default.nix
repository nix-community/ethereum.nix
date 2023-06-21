{
  essentials-openapi,
  fetchFromGitHub,
  python3Packages,
}:
with python3Packages;
  buildPythonPackage rec {
    pname = "mkdocs-plugins";
    version = "1.0.2";

    format = "pyproject";

    src = fetchFromGitHub {
      owner = "Neoteroi";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-C/HOqti8s/+V9scbS/Ch0i4sSFvRMF/K5+b6qzgTFSc=";
    };

    buildInputs = [
      essentials-openapi
      rich
    ];

    nativeBuildInputs = [
      hatchling
    ];

    propagatedBuildInputs = [
      httpx
      mkdocs
    ];

    doCheck = false;

    pythonImportsCheck = ["neoteroi.mkdocs"];
  }
