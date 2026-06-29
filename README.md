# dotfiles-ms

Reproducible bootstrap for GitHub Codespace pool machines, driven by **Nix** +
**home-manager**. No more manual `apt install` — declare a tool in `home.nix`,
re-run, and every machine converges.

## What it does

- Installs a modern, flakes-enabled **single-user Nix** (daemonless — the right
  fit for systemd-less Codespaces) if it isn't already present.
- Applies the **home-manager** config in `home.nix` (tmux, gh, git, ripgrep,
  fzf, jq, … plus a declarative tmux config with mouse support).

## Usage

### As Codespaces dotfiles (automatic)

Set this repo as your dotfiles in GitHub → Settings → Codespaces → "Automatically
install dotfiles". GitHub clones it and runs `install.sh` on every new machine.

### Manually on an existing machine

```sh
git clone https://github.com/rfeltis/dotfiles-ms ~/dotfiles-ms
~/dotfiles-ms/install.sh
```

`install.sh` is idempotent — safe to re-run.

## Adding software

Edit `home.nix`, add the package to `home.packages`, then:

```sh
nix run home-manager -- switch --flake ~/dotfiles-ms#"$(whoami)" -b backup
```

(or just re-run `install.sh`). Search package names at https://search.nixos.org/packages.

## Layout

- `flake.nix`  — inputs (nixpkgs 24.11, home-manager 24.11) + a per-user config
  (`node`, `codespace`, `vscode`, `root`) so it applies on any base image.
- `home.nix`   — the declarative package set and program config.
- `install.sh` — Nix install (if needed) + flake apply.
