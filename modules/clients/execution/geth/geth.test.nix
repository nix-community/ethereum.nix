{
  systems = ["x86_64-linux"];

  module = {pkgs, ...}: let
    netrestrict = "192.168.1.0/24";

    mkGeth = id: {
      virtualisation.cores = 2;
      virtualisation.memorySize = 4096;
      services.ethereum.geth.test = {
        enable = true;
        openFirewall = true;
        args = {
          port = 30304 + id;
          http.enable = true;
          http.port = 8544 + id;
          networkid = 12345;
          inherit netrestrict;
          # see README.md for a list of addresses
          bootnodes = [
            "enode://1ad79035e0f92b5f98a46f87d5842c02fc09d35cf3794352a08919977e40a46f0c071e3e43cf1c9b8a50c11290f78168cb00f2d46d740714d4eb319a664f3927@192.168.1.4:30301"
          ];
        };
      };
    };
  in {
    name = "basic";

    nodes = {
      geth = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;
        services.ethereum.geth.test = {
          enable = true;
          openFirewall = true;
          args = {
            http.enable = true;
            networkid = 12345;
            nodiscover = true;
            inherit netrestrict;
          };
        };
      };
    };

    testScript = ''
      # Copy in the data directory and make sure it's writable

      geth.succeed("cp -r ${./testing/geth-1} /var/lib/private/geth-test")
      geth.succeed("chmod -R 755 /var/lib/private/geth-test")

      start_all()

      geth.wait_for_unit("geth-test.service")
      geth.wait_for_open_port(30303)
      geth.wait_for_open_port(8545)
    '';
  };
}
