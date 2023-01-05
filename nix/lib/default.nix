{lib, ...} @ args: let
  mkLib = self: let
    importLib = file: import file ({inherit self;} // args);
  in {
    flakes = importLib ./flakes.nix;

    inherit (self.flakes) mkApp;
  };
in
  lib.makeExtensible mkLib
