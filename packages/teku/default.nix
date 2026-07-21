{ pkgs }: pkgs.callPackage ./package.nix { jre = pkgs.jdk25; }
