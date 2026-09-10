# dotfiles (Linux)

My personal Linux setup, managed with home-manager and Nix.
One repo, one command, and a fresh Linux machine ends up configured the same way every time.

This is the Linux counterpart to my [macOS dotfiles](https://github.com/kunchenguid/dotfiles).
The architecture is the same — a Nix flake with home-manager — but it drops nix-darwin and Homebrew and uses Nixpkgs packages directly.

## Contributing / Using This Repo

These are my personal dotfiles, shared publicly so people can read them, learn from them, and fork them freely.
Feature requests and pull requests are not accepted here, and PRs are auto-closed.
If you find a bug, please open a GitHub Issue using the bug report template.

## What you get

Running the switch builds:

- Nix user packages (ripgrep, fd, fzf, jq, lazygit, neovim, tmux, Hack Nerd Font)
- Shell (zsh, aliases, starship prompt)
- Editor (Neovim config with the rose-pine moon theme)
- Terminal (WezTerm config with the rose-pine moon theme and dimmed unfocused windows)
- Agent configs (Claude, Codex, opencode all share one AGENTS.md)
- Optional Pi theme and local extensions, generic UI settings and model overrides, plus two deliberately pinned third-party Pi packages

See the [NixOS module](#nixos-system-level-config) below if you are running NixOS — it replaces the macOS system defaults (dark mode, key repeat, dock, Finder, trackpad) with NixOS equivalents.

## Prerequisites

- Linux (any distro with Nix installed, or NixOS).
- Apple Silicon / ARM: the default `aarch64-linux` platform.
- Intel/AMD: change one line. In `flake.nix`, set `system = "x86_64-linux";` (the comment right there tells you the same thing).

### Optional: NixOS system-level config

If you are running NixOS, you can import `configuration.nix` from your `/etc/nixos/configuration.nix` to apply system-level settings (user account, SSH, Docker, keyboard layout, display manager). See [NixOS module](#nixos-system-level-config) below. On non-NixOS Linux, home-manager alone is sufficient and you do not need `configuration.nix`.

## Fresh-machine setup

On a brand new Linux machine, from a bare clone of this repo:

```sh
git clone https://github.com/kunchenguid/dotfiles-linux.git
cd dotfiles-linux
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed.
`bootstrap.sh` applies the config to your machine, so do this first.

```sh
./bootstrap.sh
```

`bootstrap.sh` does five things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Installs home-manager, if it isn't already on PATH.
3. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
4. Checks the `user` configured in `flake.nix` against your actual Linux username, and offers to fix it for you if they differ.
5. Runs the first `home-manager switch`.
   It applies this repo's flake config (pinned by `flake.lock`).

After that, `home-manager` exists and you're on the normal workflow below.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
nix build .#homeConfigurations.linux.activation-package --dry-run
```

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your Linux username and offers to set it) OR change the single `user = "kunchen"` line in `flake.nix`.
  Everything else (`home.nix`, home directory paths) is threaded from that one variable.
- **Host label** `"linux"`, in two places: `flake.nix` (the `homeConfigurations."linux"` name) and `rebuild.sh` (the `#linux` at the end of the flake reference).
- **CPU architecture**, `system` in `flake.nix` (see Prerequisites above).

**Git identity:** unlike the macOS version, this config does set your git name and email in `home.nix` (`programs.git`). Change it to your own.

**About `herdr`:** it is installed via Homebrew on macOS and is not available as a Nix package on Linux. Its config file (`home/.config/herdr/config.toml`) is still symlinked, so if you install herdr manually on Linux it will pick up the same keybindings. If you don't use it, remove the herdr symlink from `home.nix`.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Claude, Codex, and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `cc` and `co` shell aliases in `home.nix` are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
  They're convenient for me, but know what they do before you use them.

## NixOS system-level config

If you are running NixOS, point your `/etc/nixos/configuration.nix` at this repo:

```nix
{ config, pkgs, ... }:
{
  imports = [ /home/kunchen/.dotfiles/configuration.nix ];
  # ...your other NixOS config...
}
```

Then `sudo nixos-rebuild switch` applies system-level settings (user account, SSH, system packages) alongside the home-manager config that `./rebuild.sh` manages. The `configuration.nix` is a template — uncomment the Docker, SSH, and desktop sections you need.

On non-NixOS Linux distributions, skip this — home-manager handles everything you need.

## Repo tour

- `flake.nix` — the entry point.
  Wires up nixpkgs and home-manager, and declares the `linux` machine.
- `configuration.nix` — optional NixOS module: system-level config (user, SSH, Docker, display manager, keyboard).
- `home.nix` — user-level config: shell, packages, prompt, and the symlinks described below.
- `rebuild.sh` — re-applies the config after the first switch.
  Run this every time you make a change.
- `home/` — the actual config files that get symlinked into place; see below.

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list.

## Optional Pi configuration

Pi is an opt-in CLI, not a dependency this repository vendors. Install it from its owner with the [official Pi instructions](https://pi.dev), for example:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Pi keeps the downloaded npm package trees in its own unmanaged `~/.pi/agent/npm` runtime directory, outside Home Manager and Git tracking.
The model overrides in `home/.pi/agent/models.json` contain no credentials or endpoint settings, do not choose a default model, and only take effect after you authenticate Pi yourself.

### Pi Calm

`home/.pi/agent/extensions/calm` is a standalone local Pi extension. Home Manager's existing global extensions-directory link makes Pi auto-load it without another declaration. `/calm` toggles a conversation-only presentation mode and is off by default. Its choice is stored locally in `~/.pi/agent/calm` (or the directory selected by `PI_CODING_AGENT_DIR`), not in this repository or Home Manager. Adapted from Firstmate under the bundled MIT license, Calm imports no Firstmate modules and has no Firstmate runtime dependency.

When enabled, Calm hides collapsed thinking and the call/result shells for Pi's seven built-in tools (`read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`) without leaving blank transcript rows. During an active run it replaces Pi's working row with a two-line animated blue-water, yellow-boat widget. `/calm` restores Pi's stock rendering and preserves the existing Ctrl+O tool-expansion choice.

Calm never changes prompts, tool execution, model context, session data, or ordering. `/share` and `/export` use the complete stock transcript. Generic custom tools, images, and unsupported Pi transcript classes deliberately remain visible because Pi has no safe general-purpose transcript filter. If a future Pi release no longer exports the exact collapsed-thinking rendering seam, Calm logs one diagnostic and leaves only that adapter disabled; all other behavior remains available.

The `tests/pi-calm.test.sh` script covers zero-coupling, static wiring, preference persistence, rendering adapters, working-ship geometry/lifecycle, and an optional real-Pi TUI smoke test. Run it with `bash tests/pi-calm.test.sh`.

## Notes

The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
That needs network access once; after that it's offline.
Neovim and WezTerm both use the rose-pine moon theme.
Neovim keeps italics off and uses a transparent background so it matches the terminal setup.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
