{
  systems = ["x86_64-linux"];

  module = {
    name = "reth";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.reth.sepolia = {
          enable = true;
          settings = {
            chain = "sepolia";
            http = true;
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("reth-sepolia.service")

      # Without a consensus layer client, reth won't fully sync.
      # Just verify the service starts and stays running.
      basic.sleep(10)
      basic.succeed("systemctl is-active reth-sepolia.service")
    '';
  };
}
