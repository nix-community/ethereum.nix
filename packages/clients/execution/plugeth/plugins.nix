{
  buildGoModule,
  fetchFromGitHub,
  gcc,
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
        mkProviderGoModule rec {
          inherit vendorSha256 version subPackages;
          pname = "plugeth-plugin-${name}";

          src = fetchFromGitHub {
            inherit owner repo rev sha256;
          };

          doCheck = false;

          CGO_ENABLED = 1;

          ldflags = ["-s" "-w" "-buildmode=plugin" "-o=${pname}.so"];

          preBuildPhase = ''
            mkdir -p "$out/plugin/"
          '';

          # Keep the attributes around for later consumption
          passthru = attrs;
        });

  officialPlugethPlugin = rec {
    owner = "openrelayxyz";
    repo = "plugeth-plugins";
    version = "0.0.18";
    rev = "v${version}";
    sha256 = "sha256-3J6euzZxVJTf0N5ON6S1EVk2dLsNRRkrX1OcIl8Xi6g=";
    vendorSha256 = "sha256-igK0YJWgT0KXS3LRiRBzUrnU+cylnnLQQTxsChCsZ5w=";
  };
in {
  inherit mkPluGethPlugin;

  plugeth.blocktracer = mkPluGethPlugin (officialPlugethPlugin
    // {
      name = "blocktracer";
      subPackages = ["packages/blockTracer"];
    });

  plugeth.blockupdates = mkPluGethPlugin (officialPlugethPlugin
    // {
      name = "blockupdates";
      subPackages = ["packages/blockupdates"];
    });

  plugeth.parity = mkPluGethPlugin (officialPlugethPlugin
    // {
      name = "plugeth-parity";
      subPackages = ["packages/plugeth-parity"];
    });

  plugeth.is-synced = mkPluGethPlugin (officialPlugethPlugin
    // {
      name = "is-synced";
      subPackages = ["packages/isSynced"];
    });

  plugeth.get-rpc-calls = mkPluGethPlugin (officialPlugethPlugin
    // {
      subPackages = ["packages/getRPCCalls"];
    });

  plugeth.shutdown = mkPluGethPlugin (officialPlugethPlugin
    // {
      name = "shutdown";
      subPackages = ["packages/shutdown"];
    });
}
