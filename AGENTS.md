# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- This is the Linux counterpart to the macOS `dotfiles` repo. It uses a pure
  home-manager flake (no nix-darwin, no Homebrew). The host label is `linux`,
  not `mac`.
- The `home/` directory contains shared config files (nvim, wezterm, AGENTS.md,
  Pi agent configs) that are symlinked into place via `mkOutOfStoreSymlink`.
  WezTerm config drops the macOS-only `macos_window_background_blur` key.
- herdr is macOS-only (installed via Homebrew). Its config file is still
  symlinked so it works if you install herdr manually on Linux, but it is not
  packaged in the Nix config. See README.md.
- Pi and the Calm extension live entirely under `home/.pi/` and are symlinked
  as-is. They are platform-agnostic. The Calm state file (`home/.pi/agent/calm`)
  is gitignored and never managed by Home Manager.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
