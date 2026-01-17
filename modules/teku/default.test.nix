{
  systems = ["x86_64-linux"];

  module = {
    name = "teku";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.teku.sepolia = {
          enable = true;
          settings = {
            network = "sepolia";
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("teku-sepolia.service")

      # Without an execution layer client, teku won't fully sync.
      # Just verify the service starts and stays running.
      basic.sleep(10)
      basic.succeed("systemctl is-active teku-sepolia.service")
    '';
  };
}
