import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from check_maintainers import missing_maintainers

ROOT = Path(__file__).resolve().parents[3]


class MaintainersTests(unittest.TestCase):
    def test_existing_unowned_package_is_grandfathered(self):
        self.assertEqual(
            missing_maintainers({"linux": {"old": 0}}, {"linux": {"old": 0}}), []
        )

    def test_new_package_and_removed_owner_fail_on_each_platform(self):
        before = {"linux": {"old": 1}, "darwin": {"helper": None}}
        after = {"linux": {"old": 0, "new": 0}, "darwin": {"helper": 0}}
        self.assertEqual(
            missing_maintainers(before, after),
            ["darwin.helper", "linux.new", "linux.old"],
        )

    def test_new_owned_packages_and_hidden_helpers_pass(self):
        self.assertEqual(
            missing_maintainers({}, {"darwin": {"new": 1, "helper": None}}), []
        )


class ReadmeTests(unittest.TestCase):
    def test_check_detects_drift_without_writing_and_generator_repairs_it(self):
        spec = importlib.util.spec_from_file_location(
            "package_docs", ROOT / "scripts/generate-package-docs.py"
        )
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "README.md"
            original = (
                f"Intro\n{module.BEGIN_MARKER}\n\nstale\n{module.END_MARKER}\nTail\n"
            )
            path.write_text(original)
            with patch.object(module, "generate_all_docs", return_value="current"):
                self.assertTrue(module.update_readme(path, check=True))
                self.assertEqual(path.read_text(), original)
                self.assertTrue(module.update_readme(path))
                self.assertFalse(module.update_readme(path, check=True))
                self.assertTrue(path.read_text().endswith("Tail\n"))
