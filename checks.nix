{
  inputs,
  packages,
  system,
}:
{
  pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      alejandra.enable = true;
      nix-linter.enable = true;
    };
  };
}
# nix build support only pointing to a single derivation
# by including packages we can build all of them in one go
# see: https://zimbatm.com/notes/nixflakes
// packages
