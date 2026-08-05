# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup` is currently `"none"` in `configuration.nix`, as a temporary safety net while the `brews`/`casks` lists were being reconciled against what was actually installed on the machine. The end goal is `"zap"` (it forces the good habit of declaring every Homebrew package in the Nix config instead of installing things ad-hoc, which keeps the machine reproducible) - switch to it once the lists are confirmed complete, don't soften a future `"zap"` back down without asking first.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.
- This machine is managed declaratively. Never install a package ad-hoc via `brew install`, `pip install`, etc. Add it to `home.packages` in `home.nix` (or `brews`/`casks` in `configuration.nix` only if it's genuinely unavailable in nixpkgs), then apply with `./rebuild.sh` - it needs an interactive terminal for the `sudo` prompt, so ask the user to run it themselves rather than running it in the background.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
