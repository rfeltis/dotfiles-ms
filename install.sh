#!/usr/bin/env bash
# Reproducible Codespace bootstrap: install Nix (if needed) + apply the
# home-manager flake in this repo. Safe to re-run. Auto-runs as Codespaces
# dotfiles (GitHub clones this repo and executes install.sh on machine creation).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="$(whoami)"

log() { printf '\033[1;34m[dotfiles]\033[0m %s\n' "$*"; }

nix_env() {
  # Source whichever Nix profile script exists (single-user or daemon).
  if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  elif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
  export PATH="$HOME/.nix-profile/bin:$PATH"
}

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    log "Nix already present: $(nix --version)"
    return 0
  fi
  log "Installing single-user Nix (daemonless; correct for systemd-less Codespaces)..."
  # Pre-create the per-user profile dirs to dodge the single-user installer's
  # 'profile.lock: No such file or directory' bug on fresh machines.
  sudo mkdir -p /nix && sudo chown "$USER_NAME":"$USER_NAME" /nix
  mkdir -p "/nix/var/nix/profiles/per-user/$USER_NAME" \
           "/nix/var/nix/gcroots/per-user/$USER_NAME"
  curl -fsSL https://nixos.org/nix/install | sh -s -- --no-daemon --no-channel-add
}

enable_flakes() {
  mkdir -p "$HOME/.config/nix"
  if ! grep -qs 'experimental-features' "$HOME/.config/nix/nix.conf"; then
    echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"
    log "Enabled flakes for $USER_NAME."
  fi
}

apply_home() {
  if ! nix eval ".#homeConfigurations.\"$USER_NAME\".activationPackage" \
        --apply 'x: "ok"' --raw >/dev/null 2>&1; then
    log "ERROR: no home configuration for user '$USER_NAME'."
    log "Add '$USER_NAME' to the 'users' list in flake.nix, commit, and re-run."
    exit 1
  fi
  log "Building + activating home-manager config for '$USER_NAME'..."
  nix build "$REPO_DIR#homeConfigurations.\"$USER_NAME\".activationPackage" \
    -o "$HOME/.hm-activate"
  # -b backup so any pre-existing dotfile is renamed, never clobbered.
  HOME_MANAGER_BACKUP_EXT=backup "$HOME/.hm-activate/activate"
}

main() {
  install_nix
  nix_env
  enable_flakes
  apply_home
  log "Done. New tools are on PATH via ~/.nix-profile."
  log "To apply future changes: nix run home-manager -- switch --flake $REPO_DIR#$USER_NAME -b backup"
}

main "$@"
