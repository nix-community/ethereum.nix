{
  systems = ["x86_64-linux"];

  module = _: let
    netrestrict = "192.168.1.0/24";
  in {
    name = "geth-startup";

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

      geth.succeed("cp -r ${./testing/datadir/40} /var/lib/private/geth-test")
      geth.succeed("chmod -R 755 /var/lib/private/geth-test")

      start_all()

      geth.wait_for_unit("geth-test.service")
      geth.wait_for_open_port(30303)
      geth.wait_for_open_port(8545)
    '';
  };
}
