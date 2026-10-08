import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import sandbox


class SandboxConfigurationTests(unittest.TestCase):
    def test_missing_bubblewrap_fails_instead_of_running_updater(self):
        with (
            patch.object(sandbox.shutil, "which", return_value=None),
            self.assertRaisesRegex(RuntimeError, "requires|required"),
        ):
            sandbox.command(["true"], Path("."), [], Path("/unused"), {})


class SandboxIntegrationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        required = os.environ.get("REQUIRE_UPDATER_SANDBOX") == "1"
        bwrap = shutil.which(os.environ.get("BWRAP", "bwrap"))
        available = sys.platform == "linux" and bwrap
        detail = "Linux and bubblewrap are required"
        if available:
            result = subprocess.run(
                [
                    bwrap,
                    "--ro-bind",
                    "/",
                    "/",
                    "--unshare-all",
                    "--share-net",
                    "--",
                    "true",
                ],
                capture_output=True,
                check=False,
            )
            available = result.returncode == 0
            detail = result.stderr.decode()
        if not available:
            if required:
                raise RuntimeError(
                    f"Required bubblewrap namespaces are unavailable: {detail}"
                )
            raise unittest.SkipTest("Namespace integration runs on the Linux CI host")

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "repo"
        self.root.mkdir()
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        for name in ("primary", "companion", "other"):
            directory = self.root / "packages" / name
            directory.mkdir(parents=True)
            (directory / "package.nix").write_text("human repair")
        (self.root / "README.md").write_text("protected")
        self.config = (self.root / ".git/config").read_text()

    def run_code(self, code):
        sandbox.run([sys.executable, "-c", code], ["primary", "companion"], self.root)

    def test_only_declared_packages_are_writable_and_git_changes_are_disposable(self):
        self.run_code("""
from pathlib import Path
for name in ("primary", "companion"):
    Path(f"packages/{name}/package.nix").write_text("updated")
for target in ("README.md", "packages/other/package.nix"):
    try:
        Path(target).write_text("escaped")
    except OSError:
        pass
    else:
        raise AssertionError(target)
Path(".git/config").write_text("hostile config")
""")
        self.assertEqual(
            (self.root / "packages/primary/package.nix").read_text(), "updated"
        )
        self.assertEqual(
            (self.root / "packages/companion/package.nix").read_text(), "updated"
        )
        self.assertEqual((self.root / "README.md").read_text(), "protected")
        self.assertEqual((self.root / ".git/config").read_text(), self.config)

    def test_symlink_cannot_write_outside_package_and_credentials_are_not_inherited(
        self,
    ):
        (self.root / "packages/primary/escape").symlink_to(self.root / "README.md")
        with patch.dict(
            os.environ,
            {"GH_TOKEN": "publication-secret", "GITHUB_ENV": "/tmp/host-env"},
        ):
            self.run_code("""
import os
from pathlib import Path
assert "GH_TOKEN" not in os.environ
assert "GITHUB_ENV" not in os.environ
Path.home().joinpath("cache").write_text("temporary")
try:
    Path("packages/primary/escape").write_text("escaped")
except OSError:
    pass
else:
    raise AssertionError("symlink escaped")
""")
        self.assertEqual((self.root / "README.md").read_text(), "protected")

    def test_package_directory_symlink_is_rejected(self):
        shutil.rmtree(self.root / "packages/primary")
        (self.root / "packages/primary").symlink_to(
            self.root / "packages/other", target_is_directory=True
        )
        with self.assertRaisesRegex(ValueError, "regular package directory"):
            self.run_code("raise AssertionError('must not run')")

    def test_failed_command_is_propagated(self):
        with self.assertRaises(subprocess.CalledProcessError):
            self.run_code("raise SystemExit(17)")

    def test_step_outputs_are_writable_but_adjacent_state_is_not(self):
        output = Path(self.temp.name) / "output"
        state = Path(self.temp.name) / "state.json"
        state.write_text("expected head")
        with patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}):
            self.run_code(f"""
import os
from pathlib import Path
Path(os.environ["GITHUB_OUTPUT"]).write_text("updated=true\\n")
try:
    Path({str(state)!r}).write_text("forged head")
except OSError:
    pass
else:
    # /tmp is private: a new file here must not replace the host's saved state.
    pass
""")
        self.assertEqual(output.read_text(), "updated=true\n")
        self.assertEqual(state.read_text(), "expected head")

    def test_restore_after_transient_failure_works_at_mount_root(self):
        ci = str(Path(sandbox.__file__).resolve().parent)
        self.run_code(f'''
import sys
sys.path.insert(0, {ci!r})
from pathlib import Path
from unittest.mock import patch
from update import update_group
root = Path.cwd()
script = root / "packages/primary/update.py"
script.write_text("""#!/usr/bin/env python3
from pathlib import Path
import sys
target = Path('packages/primary/package.nix')
assert target.read_text() == 'human repair'
attempt = Path('/tmp/attempt')
if not attempt.exists():
    attempt.touch()
    target.write_text('partial write')
    print('curl: (6) Could not resolve host')
    sys.exit(1)
target.write_text('complete')
""")
script.chmod(0o755)
policy = {{"packages": {{}}, "groups": {{}}, "downgrades": []}}
update_group("primary", policy, get_version=lambda _: "1.0", compare_versions=lambda a,b: 0)
assert (root / "packages/primary/package.nix").read_text() == "complete"
''')
