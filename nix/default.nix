{inputs, ...}: {
  imports = [
    inputs.flake-root.flakeModule
    inputs.mission-control.flakeModule
    ./checks.nix
    ./formatter.nix
    ./shell.nix
  ];
}
