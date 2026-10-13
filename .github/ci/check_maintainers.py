"""Require maintainers for newly introduced public packages, across all systems."""

import argparse
import json
import os
import subprocess
import tempfile
from pathlib import Path

EXPR = """
let
  flake = builtins.getFlake (builtins.getEnv "CHECK_FLAKE_PATH");
in builtins.mapAttrs (_: packages:
  builtins.mapAttrs (_: pkg:
    if pkg.passthru.hideFromDocs or false then null
    else builtins.deepSeq (pkg.meta.maintainers or [])
      (builtins.length (pkg.meta.maintainers or []))
  ) packages
) flake.packages
"""


def counts(root):
    result = subprocess.run(
        ["nix", "eval", "--impure", "--json", "--expr", EXPR],
        env={**os.environ, "CHECK_FLAKE_PATH": str(root.resolve())},
        text=True,
        capture_output=True,
        check=True,
    )
    return json.loads(result.stdout)


def missing_maintainers(before, after):
    # Existing empty lists are grandfathered, but dropping an existing owner or
    # adding an unowned platform is not. Helpers becoming public are new too.
    return sorted(
        f"{system}.{name}"
        for system, packages in after.items()
        for name, count in packages.items()
        if count == 0 and before.get(system, {}).get(name) != 0
    )


def check(base, root=Path(".")):
    base_sha = subprocess.check_output(
        ["git", "rev-parse", "--verify", "--end-of-options", f"{base}^{{commit}}"],
        cwd=root,
        text=True,
    ).strip()
    with tempfile.TemporaryDirectory(prefix="maintainers-base-") as directory:
        checkout = Path(directory) / "base"
        subprocess.run(
            ["git", "worktree", "add", "--detach", str(checkout), base_sha],
            cwd=root,
            check=True,
        )
        try:
            problems = missing_maintainers(counts(checkout), counts(root))
        finally:
            subprocess.run(
                ["git", "worktree", "remove", "--force", str(checkout)],
                cwd=root,
                check=True,
            )
    if problems:
        raise SystemExit("Declare meta.maintainers for: " + ", ".join(problems))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True)
    check(parser.parse_args().base)
