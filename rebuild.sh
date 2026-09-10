#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles

# Source nix if available
[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Find home-manager
if command -v home-manager >/dev/null 2>&1; then
  HM=home-manager
elif [ -x /root/.nix-profile/bin/home-manager ]; then
  HM=/root/.nix-profile/bin/home-manager
elif [ -x /nix/store/*/bin/home-manager ]; then
  HM=$(ls -d /nix/store/*/bin/home-manager 2>/dev/null | head -1)
else
  echo "home-manager not found. Install with: nix profile install nixpkgs#home-manager"
  exit 1
fi

# "linux" is the flake host label - if you renamed it, change it in flake.nix too.
"$HM" switch --flake ~/.dotfiles#linux
