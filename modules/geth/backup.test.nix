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
    name = "geth-backup";

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

          backup = {
            enable = true;
            # increase to 5 seconds to speed up testing
            metadata.interval = 5;
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
      };
    };

    testScript = ''

      backup.start()
      backup.wait_for_unit("minio.service")

      def setup_state(node, service_name, block_number):
        # copy the datadir with the specific number of blocks already mined into the state directory for the service
        state_directory=f'/var/lib/private/{service_name}'

        node.succeed(f'cp -R ${datadir}/{block_number}/* {state_directory}')
        node.succeed(f'chmod -R 755 {state_directory}')

      def wait_for_geth(node, service_name):
        # wait for the main process to start
        node.wait_for_unit(f'{service_name}.service')
        # check the backup-related timers are active
        node.wait_for_unit(f'{service_name}-metadata.timer')
        node.wait_for_unit(f'{service_name}-backup.timer')

      def wait_for_metadata(node, service_name, block_number):
        node.systemctl(f'start {service_name}-metadata.service')
        path = f'/var/lib/{service_name}/.backup/metadata.json'
        node.wait_until_succeeds(f'[[ $(cat {path} | jq .height) = {block_number} ]]', timeout=20)

      def trigger_backup(node, service_name):
        node.systemctl(f'start {service_name}-backup.service')

        # geth should be stopped
        node.wait_until_fails(f'systemctl is-active {service_name}.service')

        # wait for backup to finish
        node.wait_until_fails(f'systemctl is-active {service_name}-backup.service')

        # geth should be restarted after the backup completes
        wait_for_geth(node, service_name)

      def verify_backup(block_number):
        print(backup.succeed("restic snapshots latest"))

        # mount the backup
        mount_dir = backup.succeed("mktemp -d").rstrip()
        backup.succeed(f'restic restore latest --target {mount_dir}')

        # compare the content hash contained within the backup with a fresh hash of the mount
        expected_content_hash = backup.wait_until_succeeds(f'cat {mount_dir}/.backup/content-hash').rstrip()
        actual_content_hash = backup.succeed(f'find {mount_dir} -path {mount_dir}/.backup -prune -type f -exec md5sum {{}} + | LC_ALL=C sort | md5sum').rstrip()

        backup.succeed(f'[ "{expected_content_hash}" = "{actual_content_hash}" ]')

      node = ext4
      service_name = "geth-test"
      block_number = 40

      setup_state(node, service_name, block_number)

      wait_for_geth(node, service_name)

      # wait for a metadata capture
      wait_for_metadata(node, service_name, block_number)

      trigger_backup(node, service_name)
      verify_backup(block_number)

    '';
  };
}
