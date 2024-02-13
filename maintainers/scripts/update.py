#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p "python311.withPackages (ps: with ps; [ click ])"

import json
import os
import subprocess

import click


def get_nixpkgs_path(path):
    result = subprocess.run(
        ["nix", "eval", "-f", path, "inputs.nixpkgs.outPath", "--json"],
        capture_output=True,
        text=True,
    )
    result.check_returncode()
    return json.loads(result.stdout)


def resolve_nixpkgs(nixpkgs, path):
    return nixpkgs if nixpkgs else get_nixpkgs_path(path)


def build_nix_args(update_nix, path, attr_path, commit):
    args = [
        update_nix,
        "--arg",
        "include-overlays",
        f"[(import {path}).overlays.default]",
        "--argstr",
        "path",
        attr_path,
    ]
    if commit:
        args.append("--argstr", "commit", "true")
    return args


@click.command()
@click.option("--commit", is_flag=True, help="Commit the changes")
@click.option(
    "--nixpkgs",
    help="Override the nixpkgs flake input with this path, it will be used for finding update.nix",
    default=None,
)
@click.argument("attr_path")
def main(commit, nixpkgs, attr_path):
    path = os.getcwd()
    nixpkgs_path = resolve_nixpkgs(nixpkgs, path)
    update_nix_bin = os.path.join(nixpkgs_path, "maintainers/scripts/update.nix")
    nix_args = build_nix_args(update_nix_bin, path, attr_path, commit)
    os.execvp("nix-shell", ["nix-shell"] + nix_args)


if __name__ == "__main__":
    main()
