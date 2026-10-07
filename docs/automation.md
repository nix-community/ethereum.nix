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
