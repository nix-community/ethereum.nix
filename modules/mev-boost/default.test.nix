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
            network = "goerli";
            relays = ["https://0x8f7b17a74569b7a57e9bdafd2e159380759f5dc3ccbd4bf600414147e8c4e1dc6ebada83c0139ac15850eb6c975e82d0@builder-relay-goerli.blocknative.com"];
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
