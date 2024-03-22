{
  systems = ["x86_64-linux"];

  module = {
    pkgs,
    lib,
    ...
  }:
    with lib; let
      wallet-generator = pkgs.writers.writeBashBin "wallet-generator" ''
        set -eu -o errtrace -o pipefail

        mkdir -p /tmp/wallet

        password=12345678
        echo $password > /tmp/wallet/password.txt

        mnemonic="tooth moon mad fun romance athlete envelope next mix divert tip top symbol resemble stock family melody desk sheriff drift bargain need jaguar method"
        echo $mnemonic > /tmp/wallet/mnemonic.txt

        ${pkgs.prysm}/bin/validator wallet create \
          --accept-terms-of-use \
          --goerli \
          --keymanager-kind="direct" \
          --mnemonic-25th-word-file /tmp/wallet/mnemonic.txt \
          --skip-mnemonic-25th-word-check true \
          --wallet-dir /tmp/wallet \
          --wallet-password-file /tmp/wallet/password.txt
      '';
    in {
      name = "prysm-validator";

      nodes = {
        machine = {
          virtualisation = {
            cores = 2;
            memorySize = 4096;
            writableStore = true;
          };

          environment.systemPackages = [wallet-generator pkgs.ethdo pkgs.prysm];

          services.ethereum.prysm-validator.test = {
            enable = true;
            args = {
              datadir = "/tmp/prysm-validator";
              network = "goerli";
              rpc = {
                enable = true;
                host = "127.0.0.1";
                port = 7000;
              };
              wallet-dir = "/tmp/wallet/";
              wallet-password-file = "/tmp/wallet/password.txt";
            };
          };

          systemd.services.prysm-validator-test.serviceConfig.ExecStartPre = ''${wallet-generator}/bin/wallet-generator'';
        };
      };

      testScript = ''
        import time

        machine.wait_for_unit("prysm-validator-test.service")
        time.sleep(5)
        machine.wait_for_unit("prysm-validator-test.service")
      '';
    };
}
