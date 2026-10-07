import copy
import datetime
import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import policy
import update

CONFIG = Path(__file__).resolve().parents[2] / "config/update-policy.json"
ROOT = Path(__file__).resolve().parents[3]


class PolicyTests(unittest.TestCase):
    def setUp(self):
        self.policy = policy.load_policy(CONFIG)

    def test_historical_downgrades_are_blocked(self):
        for name, old, new in [
            ("ethrex", "29.0.0", "28.0.0"),
            ("bor", "2.9.1", "2.9.0"),
            ("erigon", "3.5.8899", "3.5.2"),
        ]:
            with (
                self.subTest(name=name),
                self.assertRaisesRegex(ValueError, "Downgrade blocked"),
            ):
                policy.validate_version(name, old, new, self.policy, lambda a, b: 1)

    def test_exception_is_exact_and_expires(self):
        self.policy["downgrades"] = [
            {
                "package": "bor",
                "from": "2.9.1",
                "to": "2.9.0",
                "reason": "upstream withdrew release",
                "expires": "2026-10-07",
            }
        ]
        policy.validate_version(
            "bor",
            "2.9.1",
            "2.9.0",
            self.policy,
            lambda a, b: 1,
            datetime.date(2026, 10, 7),
        )
        for name, today in [
            ("bor", datetime.date(2026, 10, 8)),
            ("other", datetime.date(2026, 10, 7)),
        ]:
            with self.assertRaisesRegex(ValueError, "Downgrade blocked"):
                policy.validate_version(
                    name, "2.9.1", "2.9.0", self.policy, lambda a, b: 1, today
                )

    def test_stable_rejects_prereleases(self):
        for version in [
            "1.0.0-rc.1",
            "1.0.0-alpha.1",
            "1.0.0-beta.1",
            "1.0.0-dev",
            "1.0.0-nightly",
            "1.0.0-unstable",
            "1.0.0rc1",
            "1.0.0a1",
        ]:
            with (
                self.subTest(version=version),
                self.assertRaisesRegex(ValueError, "Prerelease"),
            ):
                policy.validate_version(
                    "geth", "0.9.0", version, self.policy, lambda a, b: -1
                )

    def test_supersim_accepts_prereleases(self):
        policy.validate_version(
            "supersim", "0.1.0-alpha.59", "0.1.0-alpha.60", self.policy, lambda a, b: -1
        )
        self.assertIn(
            "--version=unstable", policy.nix_update_args("supersim", self.policy, ROOT)
        )

    def test_unknown_versions_fail_closed(self):
        for version in ["unknown", "${builtins.readFile /etc/passwd}", "", "unstable"]:
            with self.assertRaisesRegex(ValueError, "Unrecognised"):
                policy.validate_version("geth", "1.0", version, self.policy, Mock())

    def test_rolling_same_version_allows_source_refresh(self):
        policy.validate_version(
            "svm-lists",
            "unstable",
            "unstable",
            self.policy,
            Mock(side_effect=AssertionError),
        )

    def test_same_version_hash_repair_is_allowed(self):
        policy.validate_version("dora", "1.25.0", "1.25.0", self.policy, lambda a, b: 0)

    def test_companion_request_selects_primary(self):
        self.assertEqual(policy.primary_for("rocketpoold", self.policy), "rocketpool")
        self.assertEqual(
            policy.group_for("rocketpoold", self.policy), ["rocketpool", "rocketpoold"]
        )

    def test_duplicate_group_member_is_rejected(self):
        data = copy.deepcopy(self.policy)
        data["groups"]["other"] = ["rocketpoold"]
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "policy.json"
            path.write_text(json.dumps(data))
            with self.assertRaisesRegex(ValueError, "Duplicate"):
                policy.load_policy(path)

    def test_group_updates_both_packages_before_publication(self):
        execute = Mock()
        versions = Mock(side_effect=["1.21.0", "1.21.0", "1.22.1", "1.22.1"])
        result = update.update_group(
            "rocketpoold", self.policy, versions, execute, lambda a, b: -1, ROOT
        )
        self.assertEqual(result, "1.22.1")
        self.assertEqual(
            [c.args[0][-1] for c in execute.call_args_list],
            ["rocketpool", "rocketpoold"],
        )

    def test_partial_group_update_cannot_publish(self):
        versions = Mock(side_effect=["1.21.0", "1.21.0", "1.22.1", "1.21.0"])
        with self.assertRaisesRegex(ValueError, "Companion versions"):
            update.update_group(
                "rocketpool", self.policy, versions, Mock(), lambda a, b: -1, ROOT
            )

    def test_group_failure_stops_before_output(self):
        execute = Mock(side_effect=[None, RuntimeError("hash failure")])
        versions = Mock(return_value="1.21.0")
        with self.assertRaisesRegex(RuntimeError, "hash failure"):
            update.update_group(
                "rocketpool", self.policy, versions, execute, lambda a, b: -1, ROOT
            )
        self.assertEqual(versions.call_count, 2)

    def test_tracoor_regex_accepts_real_tags(self):
        args = policy.nix_update_args("tracoor", self.policy, ROOT)
        regex = args[args.index("--version-regex") + 1]
        import re

        self.assertEqual(re.fullmatch(regex, "v0.1.0").group(1), "0.1.0")
        self.assertIsNone(re.fullmatch(regex, "v0.1.0-rc.1"))
        self.assertIsNone(re.fullmatch(regex, "other/v0.1.0"))

    def test_dora_updates_npm_hash_before_vendor_hash(self):
        spec = importlib.util.spec_from_file_location(
            "dora_update", ROOT / "packages/dora/update.py"
        )
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        events = []
        with (
            patch.object(
                module,
                "run_nix_update",
                side_effect=lambda *a: events.append(a) or True,
            ),
            patch.object(
                module, "update_npm_deps_hash", side_effect=lambda: events.append("npm")
            ),
        ):
            module.main()
        self.assertEqual(events, [("--src-only",), "npm", ("--version=skip",)])


if __name__ == "__main__":
    unittest.main()


class DiscoveryTests(unittest.TestCase):
    def test_explicit_companion_has_one_group_job(self):
        spec = importlib.util.spec_from_file_location(
            "discovery",
            ROOT / ".github/actions/discovery.py"
            if (ROOT / ".github").exists()
            else ROOT / "github/actions/discovery.py",
        )
        module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = module
        spec.loader.exec_module(module)
        info = {
            "rocketpool": {"version": "1.21.0", "skipAutoUpdate": False},
            "rocketpoold": {"version": "1.21.0", "skipAutoUpdate": False},
        }
        result = Mock(returncode=0, stdout=json.dumps(info))
        with (
            patch.object(module.subprocess, "run", return_value=result),
            patch.object(
                module, "load_policy", return_value=policy.load_policy(CONFIG)
            ),
        ):
            items = module.discover_packages("rocketpoold", "x86_64-linux")
        self.assertEqual([i.name for i in items], ["rocketpool"])

    def test_companion_opt_out_prevents_partial_update(self):
        spec = importlib.util.spec_from_file_location(
            "discovery",
            ROOT / ".github/actions/discovery.py"
            if (ROOT / ".github").exists()
            else ROOT / "github/actions/discovery.py",
        )
        module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = module
        spec.loader.exec_module(module)
        info = {
            "rocketpool": {"version": "1.21.0", "skipAutoUpdate": False},
            "rocketpoold": {"version": "1.21.0", "skipAutoUpdate": True},
        }
        result = Mock(returncode=0, stdout=json.dumps(info))
        with (
            patch.object(module.subprocess, "run", return_value=result),
            patch.object(
                module, "load_policy", return_value=policy.load_policy(CONFIG)
            ),
        ):
            self.assertEqual(module.discover_packages(None, "x86_64-linux"), [])
