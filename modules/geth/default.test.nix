{
  systems = ["x86_64-linux"];

  module = {
    name = "geth";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.geth.sepolia = {
          enable = true;
          settings = {
            sepolia = true;
            http = true;
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("geth-sepolia.service")

      # Without a consensus layer client, geth won't fully sync.
      # Just verify the service starts and stays running.
      basic.sleep(10)
      basic.succeed("systemctl is-active geth-sepolia.service")
    '';
  };
}
