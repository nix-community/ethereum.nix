{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3,
  pydantic-yaml,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "eth-validator-watcher";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kilnfi";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-qgaXlh1P++0nNhA2mDK4pb+m0tqndCpvNZdyuVvz6IQ=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
    setuptools
    pybind11
  ];

  propagatedBuildInputs = with python3.pkgs; [
    typer
    prometheus-client
    pydantic
    pydantic-settings
    pydantic-yaml
    pyyaml
    requests
    slack-sdk
    tenacity
    more-itertools
    cachetools
  ];

  # Skip dependency checks for test dependencies
  pythonRemoveDeps = [
    "pytest-timeout"
    "vcrpy"
  ];

  passthru = {
    category = "Utilities";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Ethereum validator monitor";
    longDescription = ''
      Ethereum Validator Watcher monitors the Ethereum beacon
      chain in real-time and notifies you when your validators perform certain actions. '';
    homepage = "https://github.com/kilnfi/eth-validator-watcher";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
