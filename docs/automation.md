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

## PR diagnosis and merge policy

The controller reads PR metadata, diffs, verified commit signatures, current
maintainer approvals, unresolved conversations and checks from their expected
GitHub Apps. It never checks out or executes a PR revision. Its code and policy
come from the default branch. Run it without writes using:

```sh
python3 .github/ci/reconcile.py --repo nix-community/ethereum.nix
```

A routine PR must originate from the updater App in this repository and carry
the `automated` label. Package changes may only replace literal version/hash
assignments in Nix files within the declared package group. Version changes
must satisfy the channel/downgrade policy. Source ownership, executable code,
test exclusions, new files and dependency lockfiles require a maintainer's
approval of the current head. Flake lock refreshes retain the dependency graph
and source identities. The dedicated bot README branch may update README only.

The `update-policy` check reports whether a revision qualifies for automatic
approval or already has a current maintainer approval. It fails for unsigned
commits, unresolved conversations, requested changes, drafts, conflicts or the
`automation:manual` label. Build readiness is reported separately: missing,
pending, skipped, neutral or failed required checks all prevent enqueueing.
Successful checks from a different App do not satisfy the requirement.

`merge_group` events report the same policy check on the synthetic group SHA.
The controller rechecks the target queue entry and every preceding live entry,
verifies their current heads and confirms the synthetic ref is still current.
Missing, replaced or incompletely enumerated queue state fails closed. The
existing nixbot checks and `automation-tests` validate the synthetic revision
itself; a PR-head success never substitutes for those group checks.

Reconciliation runs on PR changes, completion of nixbot's aggregate checks,
merge-group creation and every 30 minutes. The schedule also picks up human
approvals/dismissals and catches missed events. Eligible routine revisions are
approved once by GitHub Actions and auto-merge is requested with the inspected
head SHA. Ineligible revisions have an existing auto-merge request disabled.
Creation of update PRs no longer enables auto-merge directly.

### Activation after merging the three PRs

1. Merge the preservation PR, retarget/merge the validation PR, then retarget/merge
   the controller PR. Keep deletion of merged update branches enabled.

1. Run **Diagnose and reconcile PRs** manually. With the variable below unset it
   reports policy checks and diagnoses but does not grant approvals or enable
   auto-merge. It can disable an ineligible existing auto-merge request.

1. In the active `main` merge-queue ruleset, require the following checks, bound
   to their source Apps. Retain the existing queue, signatures, review and
   conversation-resolution protections.

   | Check | Source App ID |
   | --- | --- |
   | `nixbot/nix-build` | `4016365` |
   | `nixbot/nix-eval` | `4016365` |
   | `automation-tests` | `15368` (GitHub Actions) |
   | `update-policy` | `15368` (GitHub Actions) |

1. Refresh old PR branches so the new `automation-tests` workflow runs on their
   revisions. The diagnostic will show which PRs are missing it. Confirm nixbot
   and both new checks report on an actual merge-group SHA before broad rollout.

1. Set repository Actions variable `AUTOMATION_MERGE_ENABLED=true`. The controller
   additionally checks the effective ruleset: it refuses to approve or enable
   merge unless the queue and all four App-bound checks are present.

The publisher's former `auto-merge` workflow input is replaced by this
repository-level activation switch. The existing App review bypass is not
needed by the controller (which uses GitHub Actions); consider removing that
bypass during activation. Do not remove required checks to unblock a PR.
Mergify may still report statuses through organization configuration; keep one
queue authority and audit that configuration before enabling another writer.

To stop new automatic approvals/merge requests, unset the variable. Cancel any
already queued entries or enabled requests separately; unsetting the variable
is not an emergency cancellation of existing queue state. The manual label
blocks an individual PR at the next reconciliation.

### Bounded retries

Package updater commands recognise explicit curl/DNS/HTTP gateway failures and
retry once after restoring that package's complete pre-command snapshot. Go/JVM
toolchain mismatches, version-policy errors, dependency/hash errors, capacity
failures and unknown errors are diagnosed without retry. The summary includes
the category and next action. A second transient failure stops the job.

This retry applies to package update commands. External nixbot build failures
are reported with links to the failing package/platform checks; the controller
does not guess a build failure's cause from its name or repeatedly request
external rebuilds. Build diagnostics and PR inspection are read-only in the
local command above; `--apply` is required for GitHub writes.
