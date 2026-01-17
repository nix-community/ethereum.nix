{
  systems = ["x86_64-linux"];

  module = {
    name = "erigon";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.erigon.sepolia = {
          enable = true;
          settings = {
            chain = "sepolia";
            http = true;
            externalcl = true;
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("erigon-sepolia.service")

      # Without a consensus layer client, erigon won't fully sync.
      # Just verify the service starts and stays running.
      basic.sleep(10)
      basic.succeed("systemctl is-active erigon-sepolia.service")
    '';
  };
}
