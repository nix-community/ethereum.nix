{
  pkgs,
  flake,
  name,
}:
let
  definition = import (../modules/nixos + "/${name}/default.test.nix");
  test = pkgs.testers.runNixOSTest {
    imports = [ definition.module ];
    _module.args.ethereumPackages = flake.packages.${pkgs.stdenv.hostPlatform.system};
    # The module's `package` default resolves to this flake's package.
    defaults.imports = [ flake.nixosModules.${name} ];
  };
in
# Expose metadata without evaluating the Linux VM on unsupported systems.
test // { meta.platforms = definition.systems; }
