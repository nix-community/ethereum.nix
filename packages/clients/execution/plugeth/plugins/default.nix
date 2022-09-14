{
  buildGoModule,
  fetchFromGitHub,
  lib,
}: let
  mkPluGethPlugin =
    lib.makeOverridable
    ({
        name,
        owner,
        repo,
        rev,
        version,
        sha256,
        vendorSha256,
        subPackages ? ["."],
        mkProviderGoModule ? buildGoModule,
      } @ attrs:
        mkProviderGoModule {
          pname = name;
          inherit vendorSha256 version subPackages;

          src = fetchFromGitHub {
            name = "plugeth-plugin-${name}-${rev}";
            inherit owner repo rev sha256;
          };

          doCheck = false;

          CGO_ENABLED = 1;

          ldflags = ["-s" "-w" "-buildmode=plugin" "-o ${name}.so"];

          preBuildPhase = ''
            mkdir -p "$out/plugin/"
          '';

          # Keep the attributes around for later consumption
          passthru = attrs;
        });
in {
  inherit mkPluGethPlugin;

  blocktracer = mkPluGethPlugin rec {
    name = "blockupdates";
    owner = "openrelayxyz";
    repo = "plugeth-plugins";
    version = "0.0.18";
    rev = "v${version}";
    sha256 = "sha256-3J6euzZxVJTf0N5ON6S1EVk2dLsNRRkrX1OcIl8Xi6g=";
    vendorSha256 = "sha256-igK0YJWgT0KXS3LRiRBzUrnU+cylnnLQQTxsChCsZ5w=";
    subPackages = ["packages/blockTracer"];
  };

  blockupdates = mkPluGethPlugin rec {
    name = "blockupdates";
    owner = "openrelayxyz";
    repo = "plugeth-plugins";
    version = "0.0.18";
    rev = "v${version}";
    sha256 = "sha256-3J6euzZxVJTf0N5ON6S1EVk2dLsNRRkrX1OcIl8Xi6g=";
    vendorSha256 = "sha256-igK0YJWgT0KXS3LRiRBzUrnU+cylnnLQQTxsChCsZ5w=";
    subPackages = ["packages/blockupdates"];
  };

  plugeth-parity = mkPluGethPlugin rec {
    name = "blockupdates";
    owner = "openrelayxyz";
    repo = "plugeth-plugins";
    version = "0.0.18";
    rev = "v${version}";
    sha256 = "sha256-3J6euzZxVJTf0N5ON6S1EVk2dLsNRRkrX1OcIl8Xi6g=";
    vendorSha256 = "sha256-igK0YJWgT0KXS3LRiRBzUrnU+cylnnLQQTxsChCsZ5w=";
    subPackages = ["packages/plugeth-parity"];
  };

  is-synced = mkPluGethPlugin rec {
    name = "blockupdates";
    owner = "openrelayxyz";
    repo = "plugeth-plugins";
    version = "0.0.18";
    rev = "v${version}";
    sha256 = "sha256-3J6euzZxVJTf0N5ON6S1EVk2dLsNRRkrX1OcIl8Xi6g=";
    vendorSha256 = "sha256-igK0YJWgT0KXS3LRiRBzUrnU+cylnnLQQTxsChCsZ5w=";
    subPackages = ["packages/isSynced"];
  };

  get-rpc-calls = mkPluGethPlugin rec {
    name = "blockupdates";
    owner = "openrelayxyz";
    repo = "plugeth-plugins";
    version = "0.0.18";
    rev = "v${version}";
    sha256 = "sha256-3J6euzZxVJTf0N5ON6S1EVk2dLsNRRkrX1OcIl8Xi6g=";
    vendorSha256 = "sha256-igK0YJWgT0KXS3LRiRBzUrnU+cylnnLQQTxsChCsZ5w=";
    subPackages = ["packages/getRPCCalls"];
  };

  shutdown = mkPluGethPlugin rec {
    name = "blockupdates";
    owner = "openrelayxyz";
    repo = "plugeth-plugins";
    version = "0.0.18";
    rev = "v${version}";
    sha256 = "sha256-3J6euzZxVJTf0N5ON6S1EVk2dLsNRRkrX1OcIl8Xi6g=";
    vendorSha256 = "sha256-igK0YJWgT0KXS3LRiRBzUrnU+cylnnLQQTxsChCsZ5w=";
    subPackages = ["packages/shutdown"];
  };
}
