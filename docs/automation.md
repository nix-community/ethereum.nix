# Update automation

The updater keeps the head and history of an existing `update/<package>` or
`update-<input>` branch. It appends changes instead of recreating that branch
from `main`. This preserves fixes such as the ones lost in PR #1232.

Before updating it computes a merge with current `main` using `git merge-tree`.
A conflict stops the job with an actionable error; no remote ref is modified.
It does not rebase or regenerate signatures on existing commits. The merge
queue validates the integration with the latest `main`. Resolve conflicts on
the existing PR branch and rerun the affected package/input to resume.

Publication uses GitHub's `createCommitOnBranch` mutation. GitHub signs the new
commit, and `expectedHeadOid` atomically rejects a concurrent push. A competing
branch creation also fails without overwriting the other branch. Concurrency
groups serialize scheduled/manual runs for the same package or input; a human
push remains protected by the API's head check.

New changes are restricted to the package directory, `flake.lock`, or `README.md`
for their respective jobs. Existing human repairs elsewhere on a reused branch
are kept. Untracked files and deletions are included; symlinks and file-mode
changes require manual handling. Existing PR titles and descriptions are kept.
An unchanged tree does not produce a new commit or invalidate passing checks.

Keep automatic deletion of merged branches enabled in repository settings.
The publisher retains the existing App secrets (`APP_ID`, `APP_PRIVATE_KEY`),
but mints the write token only after updater execution. Checkout credentials
are not persisted. These steps reduce credential exposure; they are not a
sandbox for arbitrary hostile package updater code.

Run the branch regression tests with:

```sh
python3 -m unittest discover -s .github/ci/tests -v
```

They exercise real local Git repositories for branch reuse, advancing `main`,
conflicts, new files, deletions and scope checks. GitHub API tests verify the
atomic publication request and error handling without writing to a repository.
The `automation-tests` workflow also runs for `merge_group` events.

Reference: [llm-agents.nix updater](https://github.com/numtide/llm-agents.nix/blob/c9ef0fb47c91abf5c637218b69a018d3b37bb8d9/.github/workflows/update-flake.yml).
The branch-reuse design is adapted here to retain existing signed commits and
avoid resetting branches on conflicts or force-pushing over concurrent edits.

## Update validation

`.github/config/update-policy.json` declares channels and atomic update groups.
The default channel is `stable`; `supersim` explicitly follows prereleases, and
`svm-lists` permits same-version rolling data refreshes. Version comparisons use
Nix's `builtins.compareVersions`. Unknown versions fail instead of silently
publishing `unknown`. An exception to monotonic versions must specify the exact
package, old/new versions, an explanation and an inclusive UTC expiry date.

Requests for `rocketpoold` resolve to the `rocketpool` job, which updates both
packages and requires matching resulting versions. A failure in either updater
prevents publication of the group. Custom update scripts remain authoritative
for multi-stage hashes; the Dora regression verifies that its npm hash is
updated before recomputing the Go vendor hash. Regex tests cover the Tracoor
failure from #1301, and downgrade tests cover #1423, #1264 and #1230.

The trusted policy and orchestration are copied from the workflow revision
before checking out an existing update branch. Changing a package's version
channel requires changing the policy, rather than adding an overriding
`--version` flag to `nix-update-args`.

## Checks

`checks.<system>.automation` runs the updater regression suite.
`checks.<system>.pkgs-formatter-check` executes treefmt and rejects formatting
drift. The NixOS tests are exported on x86_64-linux as
`testing-nethermind`, `testing-prysm-validator` and `testing-mev-boost`.
They use this flake's packages, exercise the real systemd services and require
no public testnet or external relay. Prysm tests wallet initialization and
monitoring while its beacon endpoint is unavailable; it does not test validator
duties. MEV-Boost uses a local test relay. Nethermind checks its RPC chain ID,
P2P listener and metrics without waiting for chain synchronization.

```sh
nix build .#checks.x86_64-linux.automation
nix build .#checks.x86_64-linux.pkgs-formatter-check
nix build .#checks.x86_64-linux.testing-mev-boost
nix build .#checks.x86_64-linux.testing-prysm-validator
nix build .#checks.x86_64-linux.testing-nethermind
```
