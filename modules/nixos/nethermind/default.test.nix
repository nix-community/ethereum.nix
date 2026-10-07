{
  systems = [ "x86_64-linux" ];
  module =
    { pkgs, ... }:
    let
      jwtSecret = pkgs.writeText "test-jwt-secret" "315228a30b238d15df0bedd570a3e1d21bb3f92588168a26127c2090497cf4b6";
    in
    {
      name = "nethermind";
      nodes.machine = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 8192;
        environment.systemPackages = [ pkgs.curl ];
        services.ethereum.nethermind.test = {
          enable = true;
          settings = {
            config = "sepolia";
            "Init.DiscoveryEnabled" = false;
            "JsonRpc.Enabled" = true;
            "JsonRpc.JwtSecretFile" = "${jwtSecret}";
            "Metrics.Enabled" = true;
            "Metrics.ExposePort" = 1313;
          };
        };
      };
      testScript = ''
        start_all()
        machine.wait_for_unit("nethermind-test.service")
        machine.wait_for_open_port(30303)
        machine.wait_for_open_port(8545)
        machine.wait_for_open_port(1313)
        machine.wait_until_succeeds("curl -fsS -H 'Content-Type: application/json' --data '{\"jsonrpc\":\"2.0\",\"method\":\"eth_chainId\",\"params\":[],\"id\":1}' http://localhost:8545 | grep -q 0xaa36a7")
        machine.succeed("test $(systemctl show nethermind-test.service -p NRestarts --value) = 0")
        machine.succeed("systemctl show nethermind-test.service -p DynamicUser --value | grep -x yes")
      '';
    };
}
