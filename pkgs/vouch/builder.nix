{
  buildGoModule,
  mcl,
  bls,
}: let
  builder = {
    version,
    src,
    vendorHash,
  }: overrides: let
    originalAttrs = {
      inherit version src vendorHash;

      pname = "vouch";

      runVend = true;

      buildInputs = [mcl bls];

      doCheck = false;

      meta = {
        description = "An Ethereum 2 multi-node validator client";
        homepage = "https://github.com/attestantio/vouch";
        mainProgram = "vouch";
        platforms = ["x86_64-linux"];
      };

      passthru.mkPackage = builder;
    };

    overridesType = builtins.typeOf overrides;

    buildAttrs =
      if overridesType == "set"
      then originalAttrs // overrides
      else if overridesType == "lambda"
      then originalAttrs // (overrides originalAttrs)
      else throw "unsupported type '${overridesType}' for the overrides";
  in
    buildGoModule buildAttrs;
in
  builder
