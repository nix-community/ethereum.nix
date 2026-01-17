{
  systems = ["x86_64-linux"];

  module = {
    name = "prysm";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.prysm.sepolia = {
          enable = true;
          settings = {
            sepolia = true;
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("prysm-sepolia.service")

      # Without an execution layer client, prysm won't fully sync.
      # Just verify the service starts and stays running.
      basic.sleep(10)
      basic.succeed("systemctl is-active prysm-sepolia.service")
    '';
  };
}
