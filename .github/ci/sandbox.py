"""Run package updates with confined writes and disposable Git metadata on Linux."""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import uuid
from pathlib import Path

from policy import group_for, load_policy


def command(args, root, members, temporary, environ):
    if sys.platform != "linux":
        raise RuntimeError("Updater isolation requires Linux and bubblewrap")
    bwrap = shutil.which(environ.get("BWRAP", "bwrap"))
    if not bwrap:
        raise RuntimeError("bubblewrap is required; refusing an unsandboxed update")
    root = root.resolve()
    git_dir = root / ".git"
    if git_dir.is_symlink() or not git_dir.is_dir():
        raise ValueError("Use a standalone Git checkout for isolated updates")
    directories = []
    for name in members:
        directory = root / "packages" / name
        if directory.resolve() != directory or not directory.is_dir():
            raise ValueError(f"Not a regular package directory: {directory}")
        directories.append(directory)
    # nix-update may stage newly generated lockfiles. Its index, config and hooks
    # must never become the publisher's Git metadata.
    private_git = temporary / "git"
    shutil.copytree(git_dir, private_git, symlinks=True)
    cli = [
        bwrap,
        "--die-with-parent",
        "--new-session",
        "--unshare-all",
        "--share-net",
        "--cap-drop",
        "ALL",
        "--ro-bind",
        "/",
        "/",
        "--proc",
        "/proc",
        "--dev",
        "/dev",
        "--tmpfs",
        "/tmp",
        "--tmpfs",
        "/var/tmp",
        "--dir",
        "/tmp/home",
        "--ro-bind",
        str(root),
        str(root),
        "--bind",
        str(private_git),
        str(git_dir),
        "--clearenv",
        "--setenv",
        "HOME",
        "/tmp/home",
        "--setenv",
        "TMPDIR",
        "/tmp",
        "--setenv",
        "NIX_REMOTE",
        "daemon",
        "--setenv",
        "NIX_PATH",
        "nixpkgs=flake:nixpkgs",
        "--setenv",
        "PYTHONDONTWRITEBYTECODE",
        "1",
        "--setenv",
        "GIT_CONFIG_NOSYSTEM",
        "1",
        "--setenv",
        "GIT_CONFIG_GLOBAL",
        "/dev/null",
        "--chdir",
        str(root),
    ]
    # Also work when the trusted runner scripts live beneath /tmp.
    trusted = Path(__file__).resolve().parent
    cli += ["--ro-bind", str(trusted), str(trusted)]
    for directory in directories:
        cli += ["--bind", str(directory), str(directory)]
    for key in (
        "PATH",
        "LANG",
        "LC_ALL",
        "NIX_SSL_CERT_FILE",
        "SSL_CERT_FILE",
        "CURL_CA_BUNDLE",
        "GITHUB_TOKEN",
    ):
        if key in environ:
            cli += ["--setenv", key, environ[key]]
    # Expose only step outputs, never GITHUB_ENV/GITHUB_PATH or the saved head.
    for key in ("GITHUB_OUTPUT", "GITHUB_STEP_SUMMARY"):
        if key in environ:
            path = Path(environ[key]).resolve()
            path.touch(exist_ok=True)
            cli += ["--bind", str(path), str(path), "--setenv", key, str(path)]
    return [*cli, "--", *args]


def run(args, members, root=Path(".")):
    with tempfile.TemporaryDirectory(prefix="updater-sandbox-") as directory:
        cli = command(args, root, members, Path(directory), os.environ)
        # Updater logs are data, including any GitHub workflow-command syntax.
        token = uuid.uuid4().hex
        if os.environ.get("GITHUB_ACTIONS") == "true":
            print(f"::stop-commands::{token}", flush=True)
        try:
            subprocess.run(cli, check=True)
        finally:
            if os.environ.get("GITHUB_ACTIONS") == "true":
                print(f"::{token}::", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("package")
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if not args.command:
        parser.error("Provide a command to run")
    policy_path = Path(__file__).with_name("update-policy.json")
    policy = load_policy(policy_path) if policy_path.exists() else load_policy()
    run(args.command, group_for(args.package, policy))


if __name__ == "__main__":
    main()
