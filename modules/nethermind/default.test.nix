{
  systems = ["x86_64-linux"];

  module = {pkgs, ...}: let
    jwtSecret = pkgs.writeText "jwt-secret" "315228a30b238d15df0bedd570a3e1d21bb3f92588168a26127c2090497cf4b6";
  in {
    name = "basic";

    nodes = {
      basicConf = {
        # see: https://docs.nethermind.io/nethermind/first-steps-with-nethermind/system-requirements
        virtualisation.cores = 2;
        virtualisation.memorySize = 8192;

        services.ethereum.nethermind.sepolia = {
          enable = true;
          settings = {
            config = "sepolia";
            "JsonRpc.JwtSecretFile" = jwtSecret;
            "Metrics.Enabled" = true;
            "Metrics.ExposePort" = 1313;
          };
        };
      };
    };

    testScript = ''
      start_all()

      with subtest("Service starts and stays running"):
          basicConf.wait_for_unit("nethermind-sepolia.service")

          # Without a consensus layer client, Nethermind won't fully sync.
          # Just verify the service starts and stays running for a bit.
          basicConf.sleep(10)
          basicConf.succeed("systemctl is-active nethermind-sepolia.service")

          out = basicConf.succeed("systemctl status nethermind-sepolia.service")
          print(out)
    '';
  };
}
