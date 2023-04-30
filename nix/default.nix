{inputs, ...}: {
  imports = [
    inputs.flake-root.flakeModule
    inputs.devshell.flakeModule
    ./checks.nix
    ./formatter.nix
    ./shell.nix
  ];
}
