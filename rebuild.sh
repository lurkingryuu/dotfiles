#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# sudo resets PATH to a secure default that excludes /run/current-system/sw/bin,
# so a bare `sudo darwin-rebuild` fails with "command not found". Resolve the
# absolute path first (nix-darwin always installs it under the current system
# profile) and invoke that under sudo instead.
DARWIN_REBUILD="$(command -v darwin-rebuild || echo /run/current-system/sw/bin/darwin-rebuild)"
exec sudo "$DARWIN_REBUILD" switch --flake ~/.dotfiles#mac
