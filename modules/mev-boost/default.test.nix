{
  systems = ["x86_64-linux"];

  module = {
    name = "mev-boost";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.mev-boost.test = {
          enable = true;
          settings = {
            hoodi = true;
            addr = "localhost:18550";
            relays = [
              "https://0xac6e77dfe25ecd6110b8e780608cce0dab71fdd5ebea22a16c0205200f2f8e2e3ad3b71d3499c54ad14d6c21b41a37ae@boost-relay.flashbots.net"
            ];
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("mev-boost-test.service")
      basic.wait_for_open_port(18550)
    '';
  };
}
