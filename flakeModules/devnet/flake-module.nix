_localFlake: {
  flake-parts-lib,
  lib,
  ...
}:
with lib; let
  inherit (flake-parts-lib) mkPerSystemOption;
in {
  options.perSystem = mkPerSystemOption ({
    config,
    pkgs,
    lib,
    ...
  }: {
    options.devnet = mkOption {
      type = with types;
        attrsOf (submoduleWith {
          modules = [./modules];
          specialArgs = {inherit pkgs lib;};
        });
      description = ''
        Ethereum development networks made easy.
      '';
      default = {};
    };

    config = {
      packages = mapAttrs (_: c: c.outputs.build.processCompose.wrapper) config.devnet;
    };
  });
}
