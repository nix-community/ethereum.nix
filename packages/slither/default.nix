{ pkgs }: pkgs.callPackage ./package.nix { python3 = pkgs.python312; }
