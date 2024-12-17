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
          args = {
            addr = "localhost:18550";
            network = "holesky";
            relays = [
              "https://0xafa4c6985aa049fb79dd37010438cfebeb0f2bd42b115b89dd678dab0670c1de38da0c4e9138c9290a398ecd9a0b3110@boost-relay-holesky.flashbots.net"
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
