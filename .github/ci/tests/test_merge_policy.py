import copy
import json
import sys
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import diagnostics
import merge_policy as merge
import policy
import reconcile


class MergePolicyTests(unittest.TestCase):
    def setUp(self):
        self.policy = policy.load_policy(
            Path(__file__).resolve().parents[2] / "config/update-policy.json"
        )
        self.pr = {
            "state": "open",
            "draft": False,
            "user": {"login": merge.BOT},
            "labels": [{"name": "automated"}],
            "head": {"ref": "update/geth", "sha": "head", "repo": {"full_name": "o/r"}},
            "base": {"ref": "main", "repo": {"full_name": "o/r"}},
            "mergeable": True,
        }
        self.old = 'version = "1.0.0";\nhash = "sha256-YWJjZA==";\ndoCheck = true;'
        self.new = 'version = "1.0.1";\nhash = "sha256-ZWZnaA==";\ndoCheck = true;'

    def routine(self, old=None, new=None):
        return merge.routine_update(
            self.pr,
            {"packages/geth/package.nix": (old or self.old, new or self.new)},
            self.policy,
            lambda a, b: -1,
        )

    def test_routine_version_and_hash_update(self):
        self.assertTrue(self.routine())

    def test_disabling_tests_requires_human_review(self):
        self.assertFalse(
            self.routine(new=self.new.replace("doCheck = true", "doCheck = false"))
        )

    def test_adding_test_exclusion_requires_human_review(self):
        self.assertFalse(
            self.routine(new=self.new + '\ncheckFlags = [ "--skip=download" ];')
        )

    def test_source_change_requires_human_review(self):
        self.assertFalse(
            self.routine(
                self.old + '\nowner = "upstream";', self.new + '\nowner = "other";'
            )
        )

    def test_nix_interpolation_in_version_is_rejected(self):
        self.assertFalse(
            self.routine(
                new=self.new.replace("1.0.1", "${builtins.readFile /etc/passwd}")
            )
        )

    def test_fork_cannot_impersonate_bot(self):
        self.pr["head"]["repo"]["full_name"] = "fork/r"
        self.assertFalse(self.routine())

    def test_group_only_allows_declared_members(self):
        self.pr["head"]["ref"] = "update/rocketpool"
        files = {
            f"packages/{name}/package.nix": (self.old, self.new)
            for name in ["rocketpool", "rocketpoold"]
        }
        self.assertTrue(
            merge.routine_update(self.pr, files, self.policy, lambda a, b: -1)
        )
        files["packages/geth/package.nix"] = (self.old, self.new)
        self.assertFalse(
            merge.routine_update(self.pr, files, self.policy, lambda a, b: -1)
        )

    def test_flake_lock_cannot_change_repository_or_graph(self):
        before = {
            "version": 7,
            "root": "root",
            "nodes": {
                "nixpkgs": {
                    "original": {"owner": "NixOS"},
                    "locked": {
                        "owner": "NixOS",
                        "rev": "a" * 40,
                        "narHash": "sha256-YWJjZA==",
                    },
                }
            },
        }
        after = copy.deepcopy(before)
        after["nodes"]["nixpkgs"]["locked"]["rev"] = "b" * 40
        self.assertTrue(merge.routine_lock(json.dumps(before), json.dumps(after)))
        after["nodes"]["nixpkgs"]["locked"]["owner"] = "other"
        self.assertFalse(merge.routine_lock(json.dumps(before), json.dumps(after)))

    def test_approved_human_repair_is_eligible(self):
        self.assertTrue(merge.eligible(self.pr, False, True, True, False)[0])

    def test_draft_unsigned_unresolved_or_changes_requested_blocks(self):
        for change in [
            {"draft": True},
            {"reviewDecision": "CHANGES_REQUESTED"},
            {"mergeable": False},
            {"labels": [{"name": "automation:manual"}]},
        ]:
            pr = {**self.pr, **change}
            self.assertFalse(merge.eligible(pr, True, True, True, False)[0])
        self.assertFalse(merge.eligible(self.pr, True, True, False, False)[0])
        self.assertFalse(merge.eligible(self.pr, True, True, True, True)[0])

    def test_green_checks_do_not_authorise_nonroutine_diff(self):
        self.assertFalse(merge.eligible(self.pr, False, False, True, False)[0])

    def test_latest_check_and_correct_app_are_required(self):
        checks = [
            {
                "id": 1,
                "name": "build",
                "app": {"id": 123},
                "status": "completed",
                "conclusion": "success",
            },
            {
                "id": 2,
                "name": "build",
                "app": {"id": 123},
                "status": "completed",
                "conclusion": "failure",
            },
            {
                "id": 3,
                "name": "build",
                "app": {"id": 999},
                "status": "completed",
                "conclusion": "success",
            },
        ]
        self.assertEqual(
            merge.build_blockers(checks, {"build": 123}), ["build: failure"]
        )
        self.assertEqual(merge.build_blockers([], {"build": 123}), ["build: missing"])

    def test_pending_or_skipped_checks_do_not_pass(self):
        for status, conclusion in [
            ("in_progress", None),
            ("completed", "skipped"),
            ("completed", "neutral"),
        ]:
            check = {
                "id": 1,
                "name": "build",
                "app": {"id": 123},
                "status": status,
                "conclusion": conclusion,
            }
            self.assertTrue(merge.build_blockers([check], {"build": 123}))

    def test_queue_checks_every_entry_up_to_target(self):
        entries = [
            {"position": p, "pullRequest": {"number": 100 + p}} for p in [1, 2, 3]
        ]
        self.assertEqual(merge.queue_members(entries, 102), [101, 102])
        with self.assertRaisesRegex(ValueError, "no longer"):
            merge.queue_members(entries, 104)

    def test_required_policy_check_must_be_bound_to_app(self):
        rules = [
            {
                "type": "required_status_checks",
                "parameters": {
                    "required_status_checks": [
                        {"context": "update-policy", "integration_id": 15368}
                    ]
                },
            }
        ]
        rules.append({"type": "merge_queue"})
        self.assertTrue(merge.protection_ready(rules, {"update-policy": 15368}))
        self.assertFalse(merge.protection_ready(rules, {"update-policy": 999}))
        self.assertFalse(merge.protection_ready([], {"update-policy": 15368}))

    def test_dry_run_never_reports_approves_or_merges(self):
        with (
            patch.object(
                reconcile, "inspect", return_value=(self.pr, True, "Routine", [], True)
            ),
            patch.object(reconcile, "api") as api,
            patch.object(reconcile, "query") as query,
        ):
            reconcile.reconcile("o/r", 1, self.policy, apply=False, merge=True)
        api.assert_not_called()
        query.assert_not_called()

    def test_auto_merge_uses_inspected_head(self):
        self.pr["node_id"] = "PR_id"
        with patch.object(reconcile, "query") as query:
            reconcile.enable_merge(self.pr, "o/r")
        self.assertEqual(query.call_args.args[1]["input"]["expectedHeadOid"], "head")

    def test_partial_group_version_update_is_not_routine(self):
        self.pr["head"]["ref"] = "update/rocketpool"
        files = {"packages/rocketpool/package.nix": (self.old, self.new)}
        self.assertFalse(
            merge.routine_update(self.pr, files, self.policy, lambda a, b: -1)
        )

    def test_missing_required_protection_prevents_approval_and_merge(self):
        with (
            patch.object(
                reconcile, "inspect", return_value=(self.pr, True, "Routine", [], True)
            ),
            patch.object(reconcile, "report_check"),
            patch.object(reconcile, "api", return_value=[]) as api,
            patch.object(reconcile, "enable_merge") as enable,
        ):
            summary = reconcile.reconcile("o/r", 1, self.policy, apply=True, merge=True)
        self.assertIn("activation blocked", summary)
        enable.assert_not_called()
        self.assertEqual(api.call_args.args, ("repos/o/r/rules/branches/main",))

    def test_ineligible_request_is_disabled(self):
        self.pr["auto_merge"] = {"enabled": True}
        self.pr["node_id"] = "PR_id"
        with (
            patch.object(
                reconcile,
                "inspect",
                return_value=(self.pr, False, "Manual review", [], False),
            ),
            patch.object(reconcile, "report_check"),
            patch.object(reconcile, "query") as query,
        ):
            reconcile.reconcile("o/r", 1, self.policy, apply=True, merge=False)
        self.assertIn("disablePullRequestAutoMerge", query.call_args.args[0])

    def test_merge_group_reports_on_synthetic_sha(self):
        event = {
            "merge_group": {
                "head_ref": "refs/heads/gh-readonly-queue/main/pr-101-abc123",
                "head_sha": "synthetic",
            }
        }
        entries = [
            {"position": 1, "pullRequest": {"number": 101, "headRefOid": "head"}}
        ]
        data = {
            "repository": {
                "mergeQueue": {
                    "entries": {"nodes": entries, "pageInfo": {"hasNextPage": False}}
                }
            }
        }
        with (
            patch.object(reconcile, "query", return_value=data),
            patch.object(
                reconcile, "inspect", return_value=(self.pr, True, "Routine", [], True)
            ),
            patch.object(
                reconcile, "api", return_value={"object": {"sha": "synthetic"}}
            ),
            patch.object(reconcile, "report_check") as report,
        ):
            reconcile.check_group("o/r", event, self.policy, apply=True)
        self.assertEqual(report.call_args.args[1:3], ("synthetic", True))

    def test_replaced_group_never_reports_success(self):
        event = {
            "merge_group": {
                "head_ref": "refs/heads/gh-readonly-queue/main/pr-101-abc123",
                "head_sha": "old-synthetic",
            }
        }
        entries = [
            {"position": 1, "pullRequest": {"number": 101, "headRefOid": "head"}}
        ]
        data = {
            "repository": {
                "mergeQueue": {
                    "entries": {"nodes": entries, "pageInfo": {"hasNextPage": False}}
                }
            }
        }
        with (
            patch.object(reconcile, "query", return_value=data),
            patch.object(
                reconcile, "inspect", return_value=(self.pr, True, "Routine", [], True)
            ),
            patch.object(
                reconcile, "api", return_value={"object": {"sha": "new-synthetic"}}
            ),
            patch.object(reconcile, "report_check") as report,
            self.assertRaisesRegex(ValueError, "replaced"),
        ):
            reconcile.check_group("o/r", event, self.policy, apply=True)
        report.assert_not_called()


class RetryTests(unittest.TestCase):
    def test_transient_failure_restores_then_retries_once(self):
        events = []
        invoke = Mock(
            side_effect=[
                Mock(returncode=1, stdout="curl: (28) Operation timed out"),
                Mock(returncode=0, stdout="done"),
            ]
        )
        diagnostics.execute(
            ["update"],
            lambda: events.append("restore"),
            invoke,
            lambda _: events.append("wait"),
        )
        self.assertEqual(events, ["restore", "wait"])
        self.assertEqual(invoke.call_count, 2)

    def test_repeated_network_failure_stops_after_two_attempts(self):
        import subprocess

        invoke = Mock(return_value=Mock(returncode=1, stdout="HTTP error 503"))
        with self.assertRaises(subprocess.CalledProcessError):
            diagnostics.execute(["update"], Mock(), invoke, Mock())
        self.assertEqual(invoke.call_count, 2)

    def test_semantic_failures_are_never_retried(self):
        import subprocess

        for log in [
            "go.mod requires go >= 1.27.0",
            "No lock file!",
            "hash mismatch",
            "No version matched the regex",
            "test timed out",
            "No space left on device",
            "unclassified error",
        ]:
            invoke = Mock(return_value=Mock(returncode=1, stdout=log))
            restore = Mock()
            with (
                self.subTest(log=log),
                self.assertRaises(subprocess.CalledProcessError),
            ):
                diagnostics.execute(["update"], restore, invoke, Mock())
            self.assertEqual(invoke.call_count, 1)
            restore.assert_not_called()

    def test_retry_restores_real_package_files(self):
        import tempfile

        import update

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            package = root / "packages/example"
            package.mkdir(parents=True)
            target = package / "package.nix"
            target.write_text("human repair")
            script = package / "update.py"
            script.write_text(
                "#!"
                + sys.executable
                + "\n"
                + """from pathlib import Path
import sys
package = Path(__file__).parent
stamp = package.parent.parent / 'attempt'
if not stamp.exists():
    stamp.write_text('first')
    (package / 'package.nix').write_text('partial hash update')
    print('curl: (28) Operation timed out')
    sys.exit(1)
assert (package / 'package.nix').read_text() == 'human repair'
(package / 'package.nix').write_text('successful update')
"""
            )
            script.chmod(0o755)
            policy_data = {"packages": {}, "groups": {}, "downgrades": []}
            with patch.object(
                update,
                "retry_command",
                side_effect=lambda cmd, restore: diagnostics.execute(
                    cmd, restore, sleep=lambda _: None
                ),
            ):
                update.update_group(
                    "example",
                    policy_data,
                    lambda _: "1.0",
                    compare_versions=lambda a, b: 0,
                    root=root,
                )
            self.assertEqual(target.read_text(), "successful update")


if __name__ == "__main__":
    unittest.main()
