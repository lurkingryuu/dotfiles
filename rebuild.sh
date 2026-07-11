#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# sudo resets PATH to a secure default that excludes /run/current-system/sw/bin,
# so a bare `sudo darwin-rebuild` fails with "command not found". Resolve the
# absolute path first (nix-darwin always installs it under the current system
# profile) and invoke that under sudo instead.
DARWIN_REBUILD="$(command -v darwin-rebuild || echo /run/current-system/sw/bin/darwin-rebuild)"
sudo "$DARWIN_REBUILD" switch --flake ~/.dotfiles#mac

# Live-apply the space-switching settings. darwin-rebuild's own activation runs
# outside the logged-in GUI (Aqua) session, so it can't rebind the space hotkeys
# or restart the Dock (there `killall Dock` reports "No matching processes
# belonging to you"). This script runs in your interactive terminal - a real GUI
# session - so the rebind and Dock restart take effect here. If Ctrl+Arrow still
# doesn't switch spaces after this, log out and back in (the only 100% reliable
# apply for WindowServer-owned shortcuts).
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
killall Dock || true

# Self-check: confirm the four space-switching hotkeys actually landed in the
# live preference store (read through cfprefsd via `defaults export`, which is
# the state WindowServer arms from at login - not just the on-disk plist). Each
# entry must be enabled=1 with the expected (ascii, keycode, modifier) params.
# A mismatch here is the early warning that a macOS update or a stray `defaults`
# write clobbered the bindings, before you discover Ctrl+Arrow silently died.
check_space_hotkeys() {
  local plist entry id want_ascii want_key want_mod got_en got_params fail=0
  plist="$(mktemp -t symbolichotkeys)"
  trap 'rm -f "$plist"' RETURN
  if ! /usr/bin/defaults export com.apple.symbolichotkeys "$plist" 2>/dev/null; then
    echo "space-hotkeys check: could not read com.apple.symbolichotkeys" >&2
    return 1
  fi
  # id -> "ascii keycode modifier". Modifier carries the Fn bit (0x800000)
  # because arrows are function keys: Ctrl+Fn=8650752, Shift+Ctrl+Fn=8781824.
  # `enabled` is stored as a plist boolean, so plutil raw prints true (a fresh
  # `defaults write` of 1 may read back as 1) - accept either as on.
  for entry in \
    "79 65535 123 8650752" \
    "80 65535 123 8781824" \
    "81 65535 124 8650752" \
    "82 65535 124 8781824"; do
    read -r id want_ascii want_key want_mod <<<"$entry"
    got_en="$(/usr/bin/plutil -extract "AppleSymbolicHotKeys.$id.enabled" raw -o - "$plist" 2>/dev/null || echo missing)"
    got_params="$(/usr/bin/plutil -extract "AppleSymbolicHotKeys.$id.value.parameters" json -o - "$plist" 2>/dev/null || echo missing)"
    if { [ "$got_en" != "1" ] && [ "$got_en" != "true" ]; } || [ "$got_params" != "[$want_ascii,$want_key,$want_mod]" ]; then
      echo "space-hotkeys check: id $id off (enabled=$got_en params=$got_params, want enabled=on params=[$want_ascii,$want_key,$want_mod])" >&2
      fail=1
    fi
  done
  if [ "$fail" -eq 0 ]; then
    echo "space-hotkeys check: ok (Ctrl+Arrow bindings present)"
  else
    echo "space-hotkeys check: FAILED - Ctrl+Arrow space switching may not work; re-run or log out/in" >&2
    return 1
  fi
}
check_space_hotkeys || true
