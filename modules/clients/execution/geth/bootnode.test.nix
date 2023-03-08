{
  systems = ["x86_64-linux"];

  module = {
    name = "geth-bootnode";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.geth-bootnode.test = {
          enable = true;
          openFirewall = true;
          args = {
            nat = "extip:192.168.1.1";
            nodekey = ./testing/keys/alpha.key;
            netrestrict = "192.168.1.0/24";
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("geth-bootnode-test.service")
    '';
  };
}
