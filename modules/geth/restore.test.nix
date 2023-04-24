{
  systems = ["x86_64-linux"];

  module = {pkgs, ...}: let
    datadir = ./testing/datadir;

    AWS_DEFAULT_REGION = "eu-west-1";
    AWS_ACCESS_KEY_ID = "accessKey";
    AWS_SECRET_ACCESS_KEY = "secretKey";

    passFile = pkgs.writeTextFile {
      name = "password.txt";
      text = "!Pa55word";
    };

    RESTIC_REPOSITORY = "s3:http://backup:9000/test-bucket";
    RESTIC_PASSWORD_FILE = "${passFile}";
  in {
    name = "geth-restore";

    nodes = {
      backup = {pkgs, ...}: {
        environment = {
          variables = {
            inherit RESTIC_REPOSITORY RESTIC_PASSWORD_FILE;
            inherit AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY;
          };

          systemPackages = [
            pkgs.findutils
            pkgs.restic
          ];
        };

        services.minio = {
          enable = true;
          listenAddress = "0.0.0.0:9000";
          dataDir = ["/data/minio"];
          region = "eu-west-1";
          rootCredentialsFile = pkgs.writeTextFile {
            name = "credentials.env";
            text = ''
              MINIO_ROOT_USER=${AWS_ACCESS_KEY_ID}
              MINIO_ROOT_PASSWORD=${AWS_SECRET_ACCESS_KEY}
            '';
          };
        };

        networking.firewall.allowedTCPPorts = [9000];
      };

      ext4 = {
        virtualisation.cores = 2;
        virtualisation.diskSize = 4096;
        virtualisation.memorySize = 4096;

        environment.systemPackages = [
          pkgs.jq
          pkgs.tree
        ];

        services.ethereum.geth.test = {
          enable = true;
          args = {
            http.enable = true;
            networkid = 12345;
            nodiscover = true;
          };

          restore = {
            enable = true;
            snapshot = "latest";

            restic = {
              repository = RESTIC_REPOSITORY;
              passwordFile = RESTIC_PASSWORD_FILE;
              environmentFile = let
                envFile = pkgs.writeTextFile {
                  name = "restic.env";
                  text = ''
                    AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
                    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                  '';
                };
              in "${envFile}";
            };
          };
        };

        systemd.services.geth-test.serviceConfig = {
          Restart = "always";
          RestartSec = 10;
        };
      };
    };

    testScript = ''

      repo = '/data/geth-test'
      block_number = 40
      service_name = 'geth-test'

      backup.succeed(f'cp -R ${datadir}/{block_number} /tmp/{block_number}')
      backup.succeed("restic init")
      backup.succeed(f'cd /tmp/{block_number} && restic backup --tag name:geth-test ./')

      # wait for startup
      ext4.wait_for_unit("geth-test.service")
    '';
  };
}
