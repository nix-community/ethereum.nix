"""Classify updater failures and retry narrowly recognised network failures once."""

import os
import re
import subprocess
import time
from pathlib import Path

DETERMINISTIC = (
    (
        r"requires go >=|GOTOOLCHAIN=local|UnsupportedClassVersionError",
        "toolchain",
        "Update the package toolchain; rerunning the same build will not help.",
    ),
    (
        r"No version matched|Found an unstable version|Downgrade blocked|Prerelease .* not allowed",
        "version-policy",
        "Check the release channel, tag filter and downgrade policy.",
    ),
    (
        r"No lock file|hash mismatch|inconsistent vendoring",
        "dependencies",
        "Inspect source/dependency hashes and their update order.",
    ),
    (
        r"No space left on device",
        "capacity",
        "Free or increase runner storage before rerunning.",
    ),
    (
        r"Resolve conflicts|Head changed|expectedHeadOid",
        "concurrent-edit",
        "Preserve the latest branch edits and resolve conflicts before rerunning.",
    ),
)
TRANSIENT = re.compile(
    r"curl: \((?:5|6|7|18|28|35|52|56)\)|HTTP(?:Error| error| status)?[: ]+(?:502|503|504)|Temporary failure in name resolution|Could not resolve host|Connection reset by peer",
    re.IGNORECASE,
)


def classify(log):
    for pattern, category, hint in DETERMINISTIC:
        if re.search(pattern, log, re.IGNORECASE):
            return {"category": category, "retryable": False, "hint": hint}
    if TRANSIENT.search(log):
        return {
            "category": "network",
            "retryable": True,
            "hint": "Retry once after restoring the package snapshot.",
        }
    return {
        "category": "unknown",
        "retryable": False,
        "hint": "Inspect the first failing command; no automatic retry for an unclassified failure.",
    }


def execute(command, restore, invoke=None, sleep=time.sleep):
    invoke = invoke or (
        lambda cmd: subprocess.run(
            cmd,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
    )
    for attempt in range(2):
        result = invoke(command)
        print(result.stdout, end="", flush=True)
        if result.returncode == 0:
            return
        diagnosis = classify(result.stdout)
        print(f"Update failure ({diagnosis['category']}): {diagnosis['hint']}")
        if os.environ.get("GITHUB_STEP_SUMMARY"):
            with Path(os.environ["GITHUB_STEP_SUMMARY"]).open("a") as summary:
                summary.write(
                    f"- Updater failure: **{diagnosis['category']}**. {diagnosis['hint']}\n"
                )
        if attempt or not diagnosis["retryable"]:
            raise subprocess.CalledProcessError(
                result.returncode, command, output=result.stdout
            )
        restore()
        sleep(5)
