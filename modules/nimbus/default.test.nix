{
  systems = ["x86_64-linux"];

  module = {
    name = "nimbus";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.nimbus.sepolia = {
          enable = true;
          settings = {
            network = "sepolia";
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("nimbus-sepolia.service")

      # Without an execution layer client, nimbus won't fully sync.
      # Just verify the service starts and stays running.
      basic.sleep(10)
      basic.succeed("systemctl is-active nimbus-sepolia.service")
    '';
  };
}
