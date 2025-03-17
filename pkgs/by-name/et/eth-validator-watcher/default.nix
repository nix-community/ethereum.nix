{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "eth-validator-watcher";
  version = "0.7.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kilnfi";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-OhrThxzyuBSSdN/MM4wOj0yebVa219uQDW+o0xtsgTg=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    typer
    prometheus-client
    pydantic
    requests
    slack-sdk
    tenacity
    more-itertools
  ];

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "Ethereum validator monitor";
    longDescription = ''      Ethereum Validator Watcher monitors the Ethereum beacon
      chain in real-time and notifies you when your validators perform certain actions. '';
    homepage = "https://github.com/kilnfi/eth-validator-watcher";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
  };
}
