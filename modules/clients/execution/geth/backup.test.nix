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
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
          };
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
          };
          extraArgs = [
            "--networkid"
            "12345"
          ];

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
      # Copy in the data directory and make sure it's writable
      in_situ.succeed("cp -r ${datadir} /var/lib/private/geth-test")
      in_situ.succeed("chmod -R 755 /var/lib/private/geth-test")

      backup.start()

      with subtest("in-situ backup"):
        in_situ.start()
        in_situ.wait_for_unit("geth-test.service")
        in_situ.wait_for_open_port(30305)
        in_situ.wait_for_open_port(8545)

    '';
  };
}
