{
  blst,
  buildGoModule,
  fetchFromGitHub,
  lib,
}: let
  buildGeth = {
    name,
    version,
    owner,
    repo,
    sha256,
    vendorSha256 ? null,
    bins ? [
      "abidump"
      "abigen"
      "bootnode"
      "clef"
      "devp2p"
      "ethkey"
      "evm"
      "faucet"
      "geth"
      "rlpdump"
    ],
    ...
  } @ attrs: let
    attrs' = builtins.removeAttrs attrs ["name" "version" "owner" "repo" "sha256" "vendorSha256" "bins"];
  in
    buildGoModule ({
        inherit name vendorSha256;

        src = fetchFromGitHub {
          inherit owner repo sha256;
          rev = "v${version}";
        };

        ldflags = ["-s" "-w"];

        doCheck = false;

        # Move binaries to separate outputs and symlink them back to $out
        postInstall = lib.concatStringsSep "\n" (
          builtins.map (bin: "mkdir -p \$${bin}/bin && mv $out/bin/${bin} \$${bin}/bin/ && ln -s \$${bin}/bin/${bin} $out/bin/") bins
        );

        outputs = ["out"] ++ bins;

        subPackages = [
          "cmd/abidump"
          "cmd/abigen"
          "cmd/bootnode"
          "cmd/checkpoint-admin"
          "cmd/clef"
          "cmd/devp2p"
          "cmd/ethkey"
          "cmd/evm"
          "cmd/faucet"
          "cmd/geth"
          "cmd/p2psim"
          "cmd/puppeth"
          "cmd/rlpdump"
          "cmd/utils"
        ];

        # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
        tags = ["urfave_cli_no_docs"];

        meta = with lib; {
          homepage = "https://geth.ethereum.org/";
          description = "Official golang implementation of the Ethereum protocol";
          license = with licenses; [lgpl3Plus gpl3Plus];
        };
      }
      // attrs');
in {
  inherit buildGeth;

  geth = buildGeth {
    name = "geth";
    version = "1.10.23";
    owner = "ethereum";
    repo = "go-ethereum";
    sha256 = "sha256-1fEmtbHKrjuyIVrGr/vTudZ99onkNjEMvyBJt4I8KK4=";
    vendorSha256 = "sha256-Dj+xN8lr98LJyYr2FwJ7yUIJkUeUrr1fkcbj4hShJI0=";
  };

  mev-boost = buildGeth {
    name = "mev-boost";
    version = "0.8.2";
    owner = "flashbots";
    repo = "mev-boost";
    sha256 = "sha256-Cx5BL8ZR54MsuAvfVgUpC4+VMDS6gLUGgRa+sT+x3nw=";
    vendorSha256 = "sha256-HKp3zCOOiRmn25cSKlAo6/S/bqKFBmMzRbyDDwdQkzc=";
    subPackages = ["cmd/mev-boost"];
    buildInputs = [blst];
    bins = [];
  };

  mev-geth = buildGeth {
    name = "mev-geth";
    version = "1.10.19-mev0.6.1";
    owner = "flashbots";
    repo = "mev-geth";
    sha256 = "sha256-8czmwlbUHx2yR4qBlmABO/ywXGUZYYmL5wXlhxUxAqk=";
    vendorSha256 = "sha256-yOR/XLY54R2w5Dz/xDZ9mDzvYOobUxuxu355jqVPm2k=";
    bins = ["geth"];
  };
}
