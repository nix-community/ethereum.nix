{
  fetchFromGitHub,
  lib,
  stdenv,
  nim,
}:
stdenv.mkDerivation rec {
  pname = "nimbus-eth2";
  version = "22.9.0";

  src = fetchFromGitHub {
    owner = "status-im";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-xtMms528DD4mTBM+ZmnsBx6pWjMaV0wF3YFw/Y/g1rw=";
    fetchSubmodules = true;
  };

  buildInputs = [nim];

  NIM_PARAMS = "-d:release --parallelBuild:1 -d:libp2p_agents_metrics -d:KnownLibP2PAgents=nimbus,lighthouse,prysm,teku";

  meta = with lib; {
    description = "Nim implementation of the Ethereum 2.0 blockchain";
    homepage = "https://github.com/status-im/nimbus-eth2";
    license = licenses.mit;
  };
}
