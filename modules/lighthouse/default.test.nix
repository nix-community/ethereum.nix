{
  systems = ["x86_64-linux"];

  module = {
    name = "lighthouse";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.lighthouse.sepolia = {
          enable = true;
          settings = {
            network = "sepolia";
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("lighthouse-sepolia.service")

      # Without an execution layer client, lighthouse won't fully sync.
      # Just verify the service starts and stays running.
      basic.sleep(10)
      basic.succeed("systemctl is-active lighthouse-sepolia.service")
    '';
  };
}
