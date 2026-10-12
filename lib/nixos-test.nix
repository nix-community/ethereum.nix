{
  pkgs,
  flake,
  name,
}:
let
  definition = import (../modules/nixos + "/${name}/default.test.nix");
  packageName = if name == "prysm-validator" then "prysm" else name;
  test = pkgs.testers.runNixOSTest {
    imports = [ definition.module ];
    _module.args.ethereumPackages = flake.packages.${pkgs.stdenv.hostPlatform.system};
    defaults = {
      imports = [ flake.nixosModules.${name} ];
      services.ethereum.${name}.test.package =
        flake.packages.${pkgs.stdenv.hostPlatform.system}.${packageName};
    };
  };
in
# Expose metadata without evaluating the Linux VM on unsupported systems.
test // { meta.platforms = definition.systems; }
