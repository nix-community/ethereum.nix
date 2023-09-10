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
          args = {
            config = "sepolia";
            modules = {
              JsonRpc.JwtSecretFile = "${jwtSecret}";
              Metrics.Enabled = true;
              Metrics.ExposePort = 1313;
            };
          };
        };
      };
    };

    testScript = ''
      start_all()

      with subtest("Minimal (settings = null) config test"):
          basicConf.wait_for_unit("nethermind-sepolia.service")

          # TODO: Finish properly these tests once PR is merged in upstream https://github.com/NethermindEth/nethermind/pull/4320
          # basicConf.wait_for_open_port(30303)
          # basicConf.wait_for_open_port(8545)

          # out = basicConf.succeed("systemctl status nethermind-sepolia.service")
          # print(out)
    '';
  };
}
