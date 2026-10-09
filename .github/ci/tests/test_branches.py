"""Integration tests use real local repositories; GitHub publication is simulated."""

import base64
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import branches


class BranchTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.remote = root / "remote.git"
        self.repo = root / "repo"
        branches.git("init", "--bare", "--initial-branch=main", str(self.remote))
        branches.git("clone", str(self.remote), str(self.repo))
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.org")
        self.git("config", "commit.gpgsign", "false")
        self.write("packages/example/package.nix", "version=1\n")
        self.commit("Initial")
        self.git("push", "origin", "main")

    def git(self, *args):
        return branches.git(*args, cwd=self.repo).stdout.strip()

    def write(self, path, text):
        target = self.repo / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text)

    def commit(self, message):
        self.git("add", "--all")
        self.git("commit", "-m", message)
        return self.git("rev-parse", "HEAD")

    def existing_branch(self):
        self.git("checkout", "-b", "update/example")
        self.write("packages/example/fix.nix", "human repair\n")
        head = self.commit("Keep human fix")
        self.git("push", "origin", "HEAD")
        self.git("checkout", "main")
        return head

    def test_new_branch_uses_main(self):
        state = branches.prepare("package", "example", self.repo)
        self.assertFalse(state["exists"])
        self.assertEqual(state["head"], state["base"])

    def test_existing_human_commit_survives_main_advancing(self):
        head = self.existing_branch()
        self.write("unrelated.txt", "new main\n")
        self.commit("Main advanced")
        self.git("push", "origin", "main")
        state = branches.prepare("package", "example", self.repo)
        self.assertEqual(state["head"], head)
        self.assertEqual(self.git("rev-parse", "HEAD"), head)
        self.assertEqual(
            (self.repo / "packages/example/fix.nix").read_text(), "human repair\n"
        )
        self.assertEqual(
            branches.file_changes(state, self.repo), {"additions": [], "deletions": []}
        )

    def test_conflict_stops_without_changing_remote(self):
        head = self.existing_branch()
        self.write("packages/example/fix.nix", "conflicting main\n")
        self.commit("Conflict")
        self.git("push", "origin", "main")
        with self.assertRaisesRegex(RuntimeError, "Resolve conflicts"):
            branches.prepare("package", "example", self.repo)
        self.assertIn(
            head, self.git("ls-remote", "origin", "refs/heads/update/example")
        )

    def test_files_are_relative_to_preserved_head(self):
        self.existing_branch()
        state = branches.prepare("package", "example", self.repo)
        self.write("packages/example/package.nix", "version=2\n")
        self.write("packages/example/lock.json", "new lock\n")
        changes = branches.file_changes(state, self.repo)
        self.assertEqual(
            {x["path"] for x in changes["additions"]},
            {"packages/example/package.nix", "packages/example/lock.json"},
        )
        self.assertEqual(
            base64.b64decode(changes["additions"][0]["contents"]), b"new lock\n"
        )

    def test_out_of_scope_edit_is_rejected(self):
        state = branches.prepare("package", "example", self.repo)
        self.write(".github/workflows/unsafe.yml", "changed\n")
        with self.assertRaisesRegex(ValueError, "outside its scope"):
            branches.file_changes(state, self.repo)

    def test_deletion_is_published(self):
        state = branches.prepare("package", "example", self.repo)
        (self.repo / "packages/example/package.nix").unlink()
        self.assertEqual(
            branches.file_changes(state, self.repo)["deletions"],
            [{"path": "packages/example/package.nix"}],
        )

    def test_symlink_is_rejected(self):
        state = branches.prepare("package", "example", self.repo)
        (self.repo / "packages/example/link").symlink_to("/etc/passwd")
        with self.assertRaisesRegex(ValueError, "Symlink"):
            branches.file_changes(state, self.repo)

    def test_missing_remote_is_not_treated_as_missing_branch(self):
        self.git("remote", "set-url", "origin", str(self.remote / "missing"))
        with self.assertRaises(subprocess.CalledProcessError):
            branches.prepare("package", "example", self.repo)

    def test_no_change_does_not_call_github(self):
        state = branches.prepare("package", "example", self.repo)
        call = Mock()
        branches.publish(
            state, {"additions": [], "deletions": []}, "Update", "owner/repo", call
        )
        call.assert_not_called()

    def test_racing_commit_is_rejected_atomically(self):
        self.existing_branch()
        state = branches.prepare("package", "example", self.repo)
        self.write("packages/example/package.nix", "version=2\n")
        changes = branches.file_changes(state, self.repo)
        # Simulate GitHub's expectedHeadOid precondition after another writer pushes.
        current_head = "another-writers-commit"

        def github(endpoint, payload):
            self.assertEqual(endpoint, "graphql")
            self.assertEqual(
                payload["variables"]["input"]["branch"],
                {
                    "repositoryNameWithOwner": "owner/repo",
                    "branchName": "update/example",
                },
            )
            expected = payload["variables"]["input"]["expectedHeadOid"]
            self.assertEqual(expected, state["head"])
            if expected != current_head:
                raise RuntimeError("Head changed")

        with self.assertRaisesRegex(RuntimeError, "Head changed"):
            branches.publish(state, changes, "Update", "owner/repo", github)

    def test_racing_branch_creation_does_not_overwrite(self):
        state = branches.prepare("package", "example", self.repo)
        call = Mock(side_effect=RuntimeError("Reference already exists"))
        with self.assertRaisesRegex(RuntimeError, "already exists"):
            branches.publish(
                state,
                {"additions": [{"path": "x"}], "deletions": []},
                "Update",
                "o/r",
                call,
            )
        self.assertEqual(call.call_count, 1)


if __name__ == "__main__":
    unittest.main()
