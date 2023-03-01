{
  systems = ["x86_64-linux"];

  module = {pkgs, ...}: let
    datadir = ./testing/geth-1;

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
        virtualisation.cores = 2;
        virtualisation.memorySize = 4096;

        services.ethereum.geth.test = {
          enable = true;
          args = {
            port = 30305;
            http.enable = true;
            networkid = 12345;
            nodiscover = true;
          };

          backup = {
            enable = true;
            borg = {
              repo = "ssh://borg@backup/data/borgbackup/ethereum/geth-test";
              keyPath = privateKey;
            };
            schedule = "0/6:00:00";
          };
        };
      };
    };

    testScript = ''

      backup.start()
      backup.wait_for_unit("sshd.service")

      def copy_datadir(node, service_name):
        node.succeed(f'cp -R ${datadir} /var/lib/private/{service_name}')
        node.succeed(f'chmod -R 755 /var/lib/private/{service_name}')

      def wait_for_geth(node, service_name):
        node.wait_for_unit(f"{service_name}.service")
        node.wait_for_open_port(30305)
        node.wait_for_open_port(8545)

      def wait_for_metadata(node, service_name):
        node.wait_until_succeeds(f'test -f /var/lib/private/{service_name}/.metadata.json', timeout=20)

      def trigger_backup(node, service_name):
        node.systemctl(f'start {service_name}-backup.service')

        # geth should be stopped
        node.wait_until_fails(f'systemctl is-active {service_name}.service')

        # wait for backup to finish
        node.wait_until_fails(f'systemctl is-active {service_name}-backup.service')

        # geth should be restarted after the backup completes
        wait_for_geth(node, service_name)

      with subtest("in-situ backup"):
        in_situ.start()
        in_situ.wait_for_unit("geth-test.service")
        in_situ.wait_for_open_port(30305)
        in_situ.wait_for_open_port(8545)
    '';
  };
}
