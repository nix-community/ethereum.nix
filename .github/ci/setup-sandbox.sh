#!/usr/bin/env bash
set -euo pipefail

# Provision only disposable GitHub-hosted Linux runners, never a developer host.
if [[ ${RUNNER_ENVIRONMENT:-} != github-hosted || ${RUNNER_OS:-} != Linux ]]; then
  echo "Sandbox provisioning requires a GitHub-hosted Linux runner" >&2
  exit 1
fi

sudo apt-get update
sudo apt-get install -y bubblewrap apparmor
sudo install -m 755 /usr/bin/bwrap /usr/local/bin/ethereum-updater-bwrap

# Ubuntu 24.04 restricts unprivileged user namespaces. Grant this executable
# permission to construct its sandbox; keep the system-wide restriction intact.
# https://documentation.ubuntu.com/release-notes/24.04/#unprivileged-user-namespace-restrictions
if [[ -r /proc/sys/kernel/apparmor_restrict_unprivileged_userns ]] &&
  [[ $(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns) == 1 ]]; then
  sudo tee /etc/apparmor.d/ethereum-updater-bwrap >/dev/null <<'PROFILE'
abi <abi/4.0>,
include <tunables/global>
/usr/local/bin/ethereum-updater-bwrap flags=(unconfined) {
  userns,
}
PROFILE
  sudo apparmor_parser -r /etc/apparmor.d/ethereum-updater-bwrap
fi

/usr/local/bin/ethereum-updater-bwrap --ro-bind / / --unshare-all --share-net -- true
