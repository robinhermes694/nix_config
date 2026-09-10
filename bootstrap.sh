#!/usr/bin/env bash
# Takes a fresh Linux machine from nothing to a built home-manager config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: source nix daemon"
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 3: install home-manager"
if command -v home-manager >/dev/null 2>&1; then
  echo "    home-manager already on PATH, skipping"
elif [ -x /root/.nix-profile/bin/home-manager ]; then
  echo "    home-manager found at /root/.nix-profile/bin, adding to PATH"
  export PATH="/root/.nix-profile/bin:$PATH"
elif [ -x /nix/var/nix/profiles/default/bin/home-manager ]; then
  echo "    home-manager found in default profile, adding to PATH"
  export PATH="/nix/var/nix/profiles/default/bin:$PATH"
else
  echo "    installing home-manager via nix profile..."
  nix profile install nixpkgs#home-manager
  # Re-check after install
  if command -v home-manager >/dev/null 2>&1; then
    echo "    installed successfully"
  else
    echo "    install done but not on PATH, adding manually"
    HM_PATH=$(find /nix/store -maxdepth 2 -name home-manager -path '*/bin/home-manager' 2>/dev/null | head -1)
    if [ -n "$HM_PATH" ]; then
      export PATH="$(dirname "$HM_PATH"):$PATH"
    else
      echo "    ERROR: could not locate home-manager after install"
      exit 1
    fi
  fi
fi

echo "==> Step 4: ensure repo is in user's home"
# If the repo is not in the user's home, clone it there
REAL_USER="$(whoami)"
USER_HOME="$(eval echo ~"$REAL_USER")"
if [ "$DIR" != "$USER_HOME/dotfiles-linux" ] && [ "$DIR" != "$USER_HOME/.dotfiles" ]; then
  echo "    repo is not in $USER_HOME, cloning..."
  if [ -d "$USER_HOME/dotfiles-linux" ]; then
    echo "    $USER_HOME/dotfiles-linux already exists, skipping clone"
  else
    git clone https://github.com/kunchenguid/dotfiles-linux.git "$USER_HOME/dotfiles-linux"
  fi
  DIR="$USER_HOME/dotfiles-linux"
fi

echo "==> Step 5: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 6: personalize the configured username"
# Do this before any sudo call: sudo resets $USER to root, so whoami has to
# run as the real interactive user first.
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"user = \" line in flake.nix."
  echo "    Edit flake.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    flake.nix is configured for user \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  read -r -p "    Rewrite flake.nix's \"user = \" line to \"$REAL_USER\"? [y/N] " REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    sed -i -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
    echo "    Updated. Review the change with: git diff flake.nix"
  else
    echo "    Skipped. Edit the single \"user = \" line in flake.nix yourself before continuing."
    exit 1
  fi
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi

echo "==> Step 7: first home-manager switch"
# "linux" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
home-manager switch --flake ~/.dotfiles#linux

echo "==> Done. Use ./rebuild.sh for future changes."
