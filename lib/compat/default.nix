{
  flake-lock ? ./flake.lock,
  src ? ./.,
}:
with builtins; let
  flake =
    import
    (
      let
        lock = fromJSON (readFile flake-lock);
      in
        fetchTarball {
          url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
          sha256 = lock.nodes.flake-compat.locked.narHash;
        }
    )
    {inherit src;};
in
  flake
