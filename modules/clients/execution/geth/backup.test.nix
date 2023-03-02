{
  systems = ["x86_64-linux"];

  module = {pkgs, ...}: let
    datadir = ./testing/datadir;

    privateKey = pkgs.writeText "id_ed25519" ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACBx8UB04Q6Q/fwDFjakHq904PYFzG9pU2TJ9KXpaPMcrwAAAJB+cF5HfnBe
      RwAAAAtzc2gtZWQyNTUxOQAAACBx8UB04Q6Q/fwDFjakHq904PYFzG9pU2TJ9KXpaPMcrw
      AAAEBN75NsJZSpt63faCuaD75Unko0JjlSDxMhYHAPJk2/xXHxQHThDpD9/AMWNqQer3Tg
      9gXMb2lTZMn0pelo8xyvAAAADXJzY2h1ZXR6QGt1cnQ=
      -----END OPENSSH PRIVATE KEY-----
    '';
    publicKey = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHHxQHThDpD9/AMWNqQer3Tg9gXMb2lTZMn0pelo8xyv root@client
    '';
  in {
    name = "backup";

    nodes = {
      backup = {
        self,
        pkgs,
        ...
      }: {
        environment.variables = {
          # stops borg from checking it's ok to list an unencrypted repository
          BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
        };

        environment.systemPackages = [
          pkgs.borgbackup
          pkgs.findutils
        ];

        services.openssh = {
          enable = true;
          # Note these settings have been moved under settings in nixpkgs-unstable
          passwordAuthentication = false;
          kbdInteractiveAuthentication = false;
        };

        services.borgbackup.repos.ethereum = {
          authorizedKeysAppendOnly = [publicKey];
          allowSubRepos = true;
          path = "/data/borgbackup/ethereum";
        };
      };

      in_situ = {
        virtualisation.cores = 4;
        virtualisation.diskSize = 4096;
        virtualisation.memorySize = 8192;

        environment.systemPackages = [
          pkgs.jq
          pkgs.tree
        ];

        services.ethereum.geth.in-situ = {
          enable = true;
          args = {
            http.enable = true;
            networkid = 12345;
            nodiscover = true;
          };

          backup = {
            enable = true;
            borg = {
              repo = "ssh://borg@backup/data/borgbackup/ethereum/geth-in-situ";
              keyPath = privateKey;
            };
          };
        };
      };
    };

    testScript = ''

      backup.start()
      backup.wait_for_unit("sshd.service")

      def copy_datadir(node, service_name, block_number):
        state_directory=f'/var/lib/private/{service_name}'

        # copy the datadir with the specific number of blocks already mined into the state directory for the service
        node.succeed(f'cp -R ${datadir}/{block_number}/* {state_directory}')
        node.succeed(f'chmod -R 755 {state_directory}')

      def wait_for_geth(node, service_name):
        # wait for the main process to start
        node.wait_for_unit(f'{service_name}.service')
        node.wait_for_open_port(30303)
        node.wait_for_open_port(8545)

        # check the backup-related timers are active
        node.wait_for_unit(f'{service_name}-metadata.timer')
        node.wait_for_unit(f'{service_name}-backup.timer')

      def wait_for_metadata(node, service_name, block_number):
        node.systemctl(f'start {service_name}-metadata.service')

        # wait for metadata capture
        path = f'/var/lib/private/{service_name}/.backup/metadata.json'
        node.wait_until_succeeds(f'test -f {path}', timeout=20)

        # verify the expected chain height
        node.succeed(f'[[ $(cat {path} | jq .height) = {block_number} ]]')

      def trigger_backup(node, service_name):
        node.systemctl(f'start {service_name}-backup.service')

        # geth should be stopped
        node.wait_until_fails(f'systemctl is-active {service_name}.service')

        # wait for backup to finish
        node.wait_until_fails(f'systemctl is-active {service_name}-backup.service')

        # geth should be restarted after the backup completes
        wait_for_geth(node, service_name)

      def check_backup(service_name, block_number):
        backup.succeed(f'borg list /data/borgbackup/ethereum/{service_name} | head -n1 | cut -d\' \' -f1')
        backup.succeed(f'borg check --verify-data /data/borgbackup/ethereum/{service_name}')

        mount_dir = backup.succeed("mktemp -d").rstrip()
        backup.succeed(f'borg mount /data/borgbackup/ethereum/{service_name}::{block_number} {mount_dir}')

        expected_content_hash = backup.succeed(f'cat {mount_dir}/.backup/content-hash').rstrip()
        actual_content_hash = backup.succeed(f'find {mount_dir} -path {mount_dir}/.backup -prune -type f -exec md5sum {{}} + | LC_ALL=C sort | md5sum').rstrip()

        backup.succeed(f'[ "{expected_content_hash}" = "{actual_content_hash}" ]')

      with subtest("in-situ backup"):

        node = in_situ;
        service_name = "geth-in-situ";
        block_number = 20

        copy_datadir(node, service_name, block_number)
        node.start()

        wait_for_geth(node, service_name)

        # wait for a metadata capture
        wait_for_metadata(node, service_name, block_number)

        trigger_backup(node, service_name)

        check_backup(service_name, block_number)

    '';
  };
}
