{
  systems = ["x86_64-linux"];

  module = {
    pkgs,
    lib,
    ...
  }:
    with lib; {
      name = "lighthouse-validator";

      nodes = {
        machine = {
          virtualisation = {
            cores = 2;
            memorySize = 4096;
            writableStore = true;
          };

          environment.systemPackages = [pkgs.lighthouse];

          services.ethereum.lighthouse-validator.test = {
            enable = true;
            args = {
              beacon-nodes = ["http://127.0.0.1:5052"];
              network = "goerli";
            };
          };
        };
      };

      testScript = ''
        machine.wait_for_unit("lighthouse-validator-test.service")
        machine.wait_for_open_port(5064)

        # Error Logs
        machine.fail("journalctl -u lighthouse-validator-test.service | grep -e 'ERROR' -e 'CRIT'")
      '';
    };
}
