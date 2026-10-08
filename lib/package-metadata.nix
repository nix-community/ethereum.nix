# Adapted from numtide/llm-agents.nix checks/meta-{completeness,maintainers}.nix.
lib: name: pkg:
let
  meta = pkg.meta or { };
  hidden = pkg.passthru.hideFromDocs or false;
  category = pkg.passthru.category or "";
  nonEmpty = value: builtins.isString value && value != "";
  missing = lib.optionals (!hidden) (
    lib.filter (key: !(nonEmpty (meta.${key} or ""))) [
      "description"
      "homepage"
      "changelog"
    ]
    ++ lib.optional ((meta.license or [ ]) == [ ]) "license"
    ++ lib.optional ((meta.platforms or [ ]) == [ ]) "platforms"
    ++ lib.optional ((meta.sourceProvenance or [ ]) == [ ]) "sourceProvenance"
    ++ lib.optional (!nonEmpty category) "passthru.category"
    ++ lib.optional (category != "Libraries" && !nonEmpty (meta.mainProgram or "")) "mainProgram"
  );
  # Even hidden helpers must not contain unresolved maintainer references.
  maintainers = builtins.deepSeq (meta.maintainers or [ ]) (meta.maintainers or [ ]);
in
assert lib.assertMsg (builtins.isList maintainers) "${name}: meta.maintainers must be a list";
builtins.seq maintainers (
  lib.optional (missing != [ ]) "${name}: missing ${lib.concatStringsSep ", " missing}"
)
