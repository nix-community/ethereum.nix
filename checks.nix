{
  pkgs,
  self,
}: {
  #  nix-lint =
  #    pkgs.runCommand "nix-linter" {
  #      nativeBuildInputs = with pkgs; [nix-linter];
  #    } ''
  #      cp --no-preserve=mode -r ${self} source
  #      rm -rf source/.direnv # delete .direnv cache so nix-linter don't recurse it
  #      cd source
  #      HOME=$TMPDIR nix-linter --recursive
  #      touch $out
  #    '';
}
