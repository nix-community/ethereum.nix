{
  fetchFromGitHub,
  python3Packages,
}:
with python3Packages;
  buildPythonPackage rec {
    pname = "essentials";
    version = "1.1.5";

    src = fetchFromGitHub {
      owner = "Neoteroi";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-WMHjBVkeSoQ4Naj1U7Bg9j2hcoErH1dx00BPKiom9T4=";
    };

    doCheck = false;
  }
