{
  packages,
}:
final: _prev: {
  ethereum-nix = packages.${final.stdenv.hostPlatform.system} or { };
}
