{inputs, ...}: {
  imports = [
    inputs.flake-root.flakeModule
    inputs.mission-control.flakeModule
    ./checks.nix
    ./shell.nix
    ./formatter.nix
  ];
}
