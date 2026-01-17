{
  systems = ["x86_64-linux"];

  module = {
    name = "besu";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.besu.sepolia = {
          enable = true;
          settings = {
            network = "sepolia";
            rpc-http-enabled = true;
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("besu-sepolia.service")

      # Without a consensus layer client, besu won't fully sync.
      # Just verify the service starts and stays running.
      basic.sleep(10)
      basic.succeed("systemctl is-active besu-sepolia.service")
    '';
  };
}
