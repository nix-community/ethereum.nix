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
          path = "/data";
        };
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
            snapshot = "40";
            borg = {
              repo = "ssh://borg@backup/data/geth-test";
              keyPath = "/root/id_ed25519";
              #              encryption.mode = "none";
              #              strictHostKeyChecking = false;
              #              unencryptedRepoAccess = true;
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

      ext4.succeed("cp ${privateKey} /root/id_ed25519")
      ext4.succeed("chmod 0600 /root/id_ed25519")

      repo = '/data/geth-test'
      block_number=40

      backup.succeed(f'cp -R ${datadir}/{block_number}/* /tmp/{block_number}')
      backup.succeed(f'borg init --encryption none {repo}')
      backup.succeed(f'cd /tmp/{block_number}; borg create -s --verbose {repo}::{block_number} ./')

      ext4.wait_for_unit("geth-test.service")

    '';
  };
}
