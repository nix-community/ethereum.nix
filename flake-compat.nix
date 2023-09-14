{
  system ? builtins.currentSystem,
  flakeLockPath ? ./flake.lock,
  src ? ./.,
}: let
  lock = builtins.fromJSON (builtins.readFile flakeLockPath);
  inherit (lock.nodes.flake-compat.locked) owner repo rev narHash;

  flake-compat = fetchTarball {
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    sha256 = narHash;
  };
in
  import flake-compat {
    inherit system src;
  }
