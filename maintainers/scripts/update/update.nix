{
  flakePath ? ./.,
  system ? "x86_64-linux",
  input ? "nixpkgs",
  max-workers ? null,
  keep-going ? null,
  commit ? null,
  no-confirm ? null,
}: let
  flake = builtins.getFlake (builtins.toString flakePath);

  pkgs = flake.inputs.${input}.legacyPackages.${system};
  inherit (pkgs) lib;

  filterPkgsWithUpdateScript = pkgs:
    lib.filterAttrs (
      _name: pkg:
        lib.isDerivation pkg && lib.hasAttrByPath ["passthru" "updateScript"] pkg
    )
    pkgs;

  flakePkgs = flake.packages.${system};

  filteredPackages = filterPkgsWithUpdateScript flakePkgs;

  packageData = name: package: {
    inherit name;
    pname = lib.getName package;
    oldVersion = lib.getVersion package;
    inherit (package.passthru) updateScript;
    attrPath = name;
  };

  packagesJson = pkgs.writeText "packages.json" (builtins.toJSON (lib.mapAttrsToList packageData filteredPackages));

  optionalArgs =
    lib.optional (max-workers != null) "--max-workers=${toString max-workers}"
    ++ lib.optional (keep-going == "true") "--keep-going"
    ++ lib.optional (no-confirm == "true") "--no-confirm"
    ++ lib.optional (commit == "true") "--commit";

  args = [packagesJson] ++ optionalArgs;

  python = pkgs.python311.withPackages (ps:
    with ps; [
      click
    ]);
in
  pkgs.stdenv.mkDerivation {
    name = "flake-packages-update-script";
    buildCommand = ''
      echo ""
      echo "----------------------------------------------------------------"
      echo ""
      echo "Not possible to update packages using \`nix-build\`"
      echo "Please use \`nix-shell\` with this derivation."
      echo ""
      echo "----------------------------------------------------------------"
      exit 1
    '';
    shellHook = ''
      unset shellHook # Prevent contamination in nested shells.
      exec ${python}/bin/python ${./update.py} ${builtins.concatStringsSep " " args}
    '';
  }
