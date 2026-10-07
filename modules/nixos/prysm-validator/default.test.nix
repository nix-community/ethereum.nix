{
  systems = [ "x86_64-linux" ];
  module =
    { pkgs, ethereumPackages, ... }:
    let
      password = pkgs.writeText "test-wallet-password" "test-wallet-password-12345678";
      createWallet = pkgs.writeShellScript "create-test-wallet" ''
        set -eu
        export HOME="$STATE_DIRECTORY"
        if [ ! -d "$STATE_DIRECTORY/wallet" ]; then
          ${ethereumPackages.prysm}/bin/validator wallet create \
            --accept-terms-of-use --sepolia --keymanager-kind=imported \
            --wallet-dir "$STATE_DIRECTORY/wallet" \
            --wallet-password-file ${password}
        fi
      '';
    in
    {
      name = "prysm-validator";
      nodes.machine = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;
        services.ethereum.prysm-validator.test = {
          enable = true;
          settings = {
            datadir = "%S/prysm-validator-test";
            sepolia = true;
            wallet-dir = "%S/prysm-validator-test/wallet";
            wallet-password-file = "${password}";
            beacon-rpc-provider = "127.0.0.1:4000";
            monitoring-host = "127.0.0.1";
            monitoring-port = 8081;
          };
        };
        systemd.services.prysm-validator-test.serviceConfig.ExecStartPre = createWallet;
      };
      testScript = ''
        start_all()
        machine.wait_for_unit("prysm-validator-test.service")
        machine.wait_for_open_port(8081)
        machine.wait_until_succeeds("journalctl -u prysm-validator-test.service | grep -i 'wallet'")
        machine.succeed("test $(systemctl show prysm-validator-test.service -p NRestarts --value) = 0")
        machine.succeed("systemctl show prysm-validator-test.service -p DynamicUser --value | grep -x yes")
      '';
    };
}
