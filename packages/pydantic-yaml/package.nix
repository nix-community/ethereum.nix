{
  lib,
  fetchFromGitHub,
  python3,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "pydantic-yaml";
  version = "1.6.0";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "NowanIlfideme";
    repo = "pydantic-yaml";
    tag = "v${version}";
    hash = "sha256-n5QWVHgYAg+Ad7Iv6CBSRQcl8lv4ZtcFMiC2ZHyi414=";
  };

  postPatch = ''
    substituteInPlace src/pydantic_yaml/version.py \
      --replace-fail "0.0.0" "${version}"

    # Relax ruamel.yaml upper bound (https://github.com/NowanIlfideme/pydantic-yaml/issues/305)
    substituteInPlace pyproject.toml \
      --replace-fail "ruamel.yaml>=0.17.0,<0.19.0" "ruamel.yaml>=0.17.0,<0.20.0"
  '';

  build-system = [ python3.pkgs.setuptools-scm ];

  dependencies = with python3.pkgs; [
    pydantic
    ruamel-yaml
    typing-extensions
  ];

  pythonImportsCheck = [ "pydantic_yaml" ];

  nativeCheckInputs = with python3.pkgs; [
    pytest-mock
    pytestCheckHook
  ];

  meta = {
    description = "Small helper library that adds some YAML capabilities to pydantic";
    homepage = "https://github.com/NowanIlfideme/pydantic-yaml";
    changelog = "https://github.com/NowanIlfideme/pydantic-yaml/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
