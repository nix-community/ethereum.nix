{
stdenv,
fetchFromGitHub,
fetchYarnDeps,
nodePackages,
}: let
  name = "lodestar";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "ChainSafe";
    repo = "lodestar";
    ref = "refs/tags/v${version}";
    hash = "";
  };

  yarnDeps = stdenv.mkDerivation {
    yarnLock = "${src}/yarn.lock";
    hash = "";

  };
in yarnDeps
# in stdenv.mkDerivation {
  # inherit name version src;
# }
