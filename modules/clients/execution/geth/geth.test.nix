{
  systems = ["x86_64-linux"];

  module = {pkgs, ...}: let
    datadir = ./testing/datadir;
    jwtSecret = pkgs.writeText "jwt-secret" "315228a30b238d15df0bedd570a3e1d21bb3f92588168a26127c2090497cf4b6";
  in {
    name = "basic";

    nodes = {
      basic = {
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.geth.test = {
          enable = true;
          args = {
            port = 30305;
            http.enable = true;
          };
          extraArgs = [
            "--networkid"
            "12345"
          ];
        };
      };
    };

    testScript = ''
      # Copy in the data directory and make sure it's writable

      basic.succeed("cp -r ${datadir} /var/lib/private/geth-test")
      basic.succeed("chmod -R 755 /var/lib/private/geth-test")

      basic.start()
      basic.wait_for_unit("geth-test.service")
      basic.wait_for_open_port(30305)
      basic.wait_for_open_port(8545)
    '';
  };
}
