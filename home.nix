{ config, pkgs, lib, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  # Rebind Ctrl+Arrow to switch Spaces. macOS shipped these four hotkeys marked
  # "enabled" but with no key binding (the value/parameters block was missing),
  # so Ctrl+Left / Ctrl+Right did nothing. -dict-add merges only entries 79-82
  # and leaves the rest of AppleSymbolicHotKeys (Spotlight, screenshots, input
  # switching, ...) untouched. Params: (ASCII=65535 for arrows, keycode
  # 123=Left/124=Right, modifier 262144=Ctrl / 393216=Ctrl+Shift).
  home.activation.spaceSwitchHotkeys =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      hk() {
        $DRY_RUN_CMD /usr/bin/defaults write com.apple.symbolichotkeys.plist \
          AppleSymbolicHotKeys -dict-add "$1" \
          "{enabled=1;value={parameters=($2,$3,$4);type=standard;};}"
      }
      hk 79 65535 123 262144   # Ctrl+Left        -> move left a space
      hk 80 65535 123 393216   # Ctrl+Shift+Left  -> move left a space with window
      hk 81 65535 124 262144   # Ctrl+Right       -> move right a space
      hk 82 65535 124 393216   # Ctrl+Shift+Right -> move right a space with window
      $DRY_RUN_CMD /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
    '';

  # Fix brew's zsh completion under nix-homebrew. nix-homebrew moves the Homebrew
  # repo into the (versioned) Nix store, so the completion at $HOMEBREW_PREFIX/
  # completions/zsh/_brew no longer exists and any leftover _brew symlink dangles
  # -> compinit prints "no such file: .../site-functions/_brew". The target below
  # routes through the nix-managed Library/Homebrew symlink with ..,  so it always
  # resolves to the current store path and survives brew upgrades.
  home.activation.brewZshCompletion =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      sf=/opt/homebrew/share/zsh/site-functions
      if [ -d "$sf" ]; then
        $DRY_RUN_CMD /bin/ln -sfn \
          "../../../Library/Homebrew/../../completions/zsh/_brew" "$sf/_brew"
      fi
    '';
}
