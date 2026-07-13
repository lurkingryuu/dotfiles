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
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    JAVA_HOME = "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home";
    LDFLAGS = "-L/opt/homebrew/opt/llvm/lib";
    CPPFLAGS = "-I/opt/homebrew/opt/llvm/include";
    BUN_INSTALL = "${config.home.homeDirectory}/.bun";
    NVM_DIR = "${config.home.homeDirectory}/.nvm";
    MANPATH = "/opt/local/share/man:$MANPATH";
  };

  # Extra PATH entries beyond what nix/home-manager already put on PATH.
  # Kept as one deduped list (home-manager sources it once via
  # hm-session-vars.sh) instead of the ad-hoc, partly-duplicated `path=()`
  # rebuild and copy-pasted `echo $PATH` line this replaced in ~/.zshrc.
  home.sessionPath = [
    "/opt/local/bin"                                     # MacPorts
    "/opt/local/sbin"                                     # MacPorts
    "/Library/TeX/texbin"
    "${config.home.homeDirectory}/scripts"
    "/opt/homebrew/opt/llvm/bin"
    "/opt/homebrew/opt/make/libexec/gnubin"
    "${config.home.homeDirectory}/.local/bin"
    "/opt/homebrew/opt/postgresql@15/bin"
    "/opt/homebrew/opt/postgresql@17/bin"
    "/Applications/Sublime Text.app/Contents/SharedSupport/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/go/bin"
    "${config.home.homeDirectory}/Library/Application Support/JetBrains/Toolbox/scripts"
    "${config.home.homeDirectory}/.antigravity/antigravity/bin"
    "${config.home.homeDirectory}/.lmstudio/bin"
    "${config.home.homeDirectory}/Library/pnpm"
    "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin"
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      source ~/.orbstack/shell/init.zsh 2>/dev/null || :
    '';
    initContent = ''
      bindkey '^f' autosuggest-accept

      # ===== conda (self-managed by `conda init`, not by Nix) =====
      __conda_setup="$('${config.home.homeDirectory}/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
        eval "$__conda_setup"
      elif [ -f "${config.home.homeDirectory}/anaconda3/etc/profile.d/conda.sh" ]; then
        . "${config.home.homeDirectory}/anaconda3/etc/profile.d/conda.sh"
      fi
      unset __conda_setup

      # ===== nvm (self-managed, installed via the nvm Homebrew formula) =====
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

      # ===== zoxide: `z`/`zi` + cd override =====
      eval "$(zoxide init zsh)"
      alias cd="z"
      alias cdi="zi"

      # ===== thefuck =====
      eval $(thefuck --alias)

      # ===== ngrok completion, only if ngrok is installed =====
      if command -v ngrok &>/dev/null; then
        eval "$(ngrok completion)"
      fi

      # ===== terraform completion =====
      autoload -U +X bashcompinit && bashcompinit
      complete -o nospace -C /opt/homebrew/bin/terraform terraform

      # ===== poetry, only if installed =====
      if command -v poetry &>/dev/null; then
        poetry config virtualenvs.in-project true
      fi

      # ===== bun completions =====
      [ -s "${config.home.homeDirectory}/.bun/_bun" ] && source "${config.home.homeDirectory}/.bun/_bun"

      # ===== start ssh-agent once per login, add keys from Keychain =====
      if [[ -z "$SSH_AGENT_PID" ]] && ! pgrep -u "$USER" ssh-agent > /dev/null 2>&1; then
        eval "$(ssh-agent -s)" > /dev/null 2>&1
        ssh-add --apple-use-keychain > /dev/null 2>&1
      fi

      git_current_branch() {
        git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||'
      }

      HISTFILE="${config.home.homeDirectory}/.zsh_history"
      HISTSIZE=10000000
      SAVEHIST=10000000
      setopt BANG_HIST HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS
      setopt HIST_FIND_NO_DUPS HIST_IGNORE_SPACE HIST_SAVE_NO_DUPS HIST_REDUCE_BLANKS
      setopt HIST_VERIFY HIST_BEEP EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";

      please = "sudo";
      md = "mkdir -p";
      history = "fc -l 1";
      grep = "grep --color=auto";
      pdfpgs = "mdls -name kMDItemNumberOfPages";
      gitzip = "git archive HEAD -o \${PWD##*/}.zip";

      # eza-backed ls family
      ls = "eza";
      l = "eza -lah";
      la = "eza -a";
      ll = "eza -l";
      lla = "eza -la";

      # gcc/g++ pinned to the Homebrew `gcc` formula's versioned binaries
      "g++" = "g++-15";
      gcc = "gcc-15";

      # git (oh-my-zsh git-plugin-style aliases)
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gau = "git add --update";
      gb = "git branch";
      gba = "git branch -a";
      gbd = "git branch -d";
      gc = "git commit -v";
      gca = "git commit -v -a";
      gcam = "git commit -a -m";
      gcb = "git checkout -b";
      gcf = "git config --list";
      gcl = "git clone --recursive";
      gclean = "git clean -fd";
      gcm = "git checkout master";
      gcmsg = "git commit -m";
      gco = "git checkout";
      gcount = "git shortlog -sn";
      gcp = "git cherry-pick";
      gcs = "git commit -S";
      gd = "git diff";
      gdca = "git diff --cached";
      gdt = "git diff-tree --no-commit-id --name-only -r";
      gdw = "git diff --word-diff";
      gf = "git fetch";
      gfa = "git fetch --all --prune";
      gfo = "git fetch origin";
      ggpull = "git pull origin \"$(git_current_branch)\"";
      ggpush = "git push origin \"$(git_current_branch)\"";
      ggsup = "git branch --set-upstream-to=origin/$(git_current_branch)";
      ghh = "git help";
      gignore = "git update-index --assume-unchanged";
      gignored = "git ls-files -v | grep \"^[[:lower:]]\"";
      "git-svn-dcommit-push" = "git svn dcommit && git push github master:svntrunk";
      gk = "\\gitk --all --branches";
      gke = "\\gitk --all $(git log -g --pretty=%h)";
      gl = "git pull";
      glg = "git log --stat --max-count=10";
      glgg = "git log --graph --max-count=10";
      glgga = "git log --graph --decorate --all";
      glo = "git log --oneline --decorate --color";
      glol = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      glola = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
      gm = "git merge";
      gmom = "git merge origin/master";
      gmt = "git mergetool --no-prompt";
      gmtvim = "git mergetool --no-prompt --tool=vimdiff";
      gmum = "git merge upstream/master";
      gp = "git push";
      gpd = "git push --dry-run";
      gpoat = "git push origin --all && git push origin --tags";
      gpristine = "git reset --hard && git clean -dfx";
      gpt = "git push --tags";
      gpu = "git push upstream";
      gpv = "git push -v";
      gr = "git remote";
      gra = "git remote add";
      grb = "git rebase";
      grba = "git rebase --abort";
      grbc = "git rebase --continue";
      grbi = "git rebase -i";
      grbm = "git rebase master";
      grbs = "git rebase --skip";
      grh = "git reset HEAD";
      grhh = "git reset HEAD --hard";
      grmv = "git remote rename";
      grrm = "git remote remove";
      grset = "git remote set-url";
      grt = "cd $(git rev-parse --show-toplevel || echo \".\")";
      gru = "git reset --";
      grup = "git remote update";
      grv = "git remote -v";
      gsb = "git status -sb";
      gsd = "git svn dcommit";
      gsi = "git submodule init";
      gsps = "git show --pretty=short --show-signature";
      gsr = "git svn rebase";
      gss = "git status -s";
      gst = "git status";
      gsta = "git stash save";
      gstaa = "git stash apply";
      gstall = "git stash --all";
      gstc = "git stash clear";
      gstd = "git stash drop";
      gstl = "git stash list";
      gstp = "git stash pop";
      gsts = "git stash show --text";
      gsu = "git submodule update";
      gts = "git tag -s";
      gunignore = "git update-index --no-assume-unchanged";
      gunwip = "git log -n 1 | grep -q -c \"\\-\\-wip\\-\\-\" && git reset HEAD~1";
      gup = "git pull --rebase";
      gupa = "git pull --rebase --autostash";
      gupav = "git pull --rebase --autostash -v";
      gupv = "git pull --rebase -v";
      gwch = "git whatchanged -p --abbrev-commit --pretty=medium";
      gwip = "git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit -m \"--wip--\"";
    };
  };

  # Git identity, GPG-over-SSH commit signing, and LFS - previously a manual,
  # unmanaged ~/.gitconfig. lfs.enable both installs git-lfs and writes the
  # `[filter "lfs"]` block that `git lfs install` would otherwise write.
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_rsa.pub";
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Karthikeya";
        email = "yelisettikarthik0@gmail.com";
      };
      core.compression = 0;
      http.postBuffer = 524288000;
      gpg."ssh".allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
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
  # 123=Left/124=Right, modifier).
  #
  # The modifier MUST include the Fn bit (0x800000 = 8388608). macOS treats the
  # arrow keys as function keys, so a real Ctrl+Left keystroke arrives with flags
  # Control|Fn. A binding of plain Control (262144) never matches it, so the
  # shortcut silently does nothing - that was the original bug. The correct
  # values are Control+Fn = 8650752 (0x840000) and Shift+Control+Fn = 8781824
  # (0x860000). (`activateSettings -u` re-canonicalizes a plain-Control value by
  # adding Fn, which is why it appeared to "fix itself" once - don't rely on that;
  # write the matching value here.)
  home.activation.spaceSwitchHotkeys =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # WindowServer stores these parameters as *integers*. `defaults write
      # -dict-add "{parameters=(65535,...)}"` parses the old-style ASCII plist,
      # where every unquoted scalar becomes a *string* ("65535"), and a
      # string-typed binding is silently ignored - that's the real reason
      # Ctrl+Arrow dies. Export the domain, splice in properly typed JSON with
      # plutil (JSON numbers -> plist integers), then import it back through
      # cfprefsd so the live store WindowServer arms from is updated.
      plist="$(/usr/bin/mktemp -t symbolichotkeys)"
      /usr/bin/defaults export com.apple.symbolichotkeys "$plist" 2>/dev/null \
        || printf '<?xml version="1.0"?><plist version="1.0"><dict/></plist>' > "$plist"
      # Ensure the parent dict exists before writing nested keypaths, without
      # clobbering any hotkeys already present.
      /usr/bin/plutil -extract AppleSymbolicHotKeys json -o /dev/null "$plist" 2>/dev/null \
        || /usr/bin/plutil -replace AppleSymbolicHotKeys -json '{}' "$plist"
      hk() {
        $DRY_RUN_CMD /usr/bin/plutil -replace "AppleSymbolicHotKeys.$1" -json \
          "{\"enabled\":1,\"value\":{\"type\":\"standard\",\"parameters\":[$2,$3,$4]}}" \
          "$plist"
      }
      hk 79 65535 123 8650752   # Ctrl+Left        -> move left a space
      hk 80 65535 123 8781824   # Ctrl+Shift+Left  -> move left a space with window
      hk 81 65535 124 8650752   # Ctrl+Right       -> move right a space
      hk 82 65535 124 8781824   # Ctrl+Shift+Right -> move right a space with window
      $DRY_RUN_CMD /usr/bin/defaults import com.apple.symbolichotkeys "$plist"
      /bin/rm -f "$plist"
      # This activation writes the hotkey *values*, but binding them live and
      # restarting the Dock/WindowServer (which own space switching) can't happen
      # here: darwin-rebuild activation runs outside the logged-in GUI (Aqua)
      # session, so `killall Dock` finds nothing ("No matching processes belonging
      # to you"). The live re-apply is done in rebuild.sh instead, which runs in
      # your interactive terminal - a real GUI session. activateSettings is safe
      # to call from here though, so keep it as a best-effort rebind.
      $DRY_RUN_CMD /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
    '';

  # Mouse tracking speed (com.apple.mouse.scaling) has no typed nix-darwin
  # system.defaults option - only trackpad scaling does - so it's set here
  # directly, the same way as the other per-user defaults writes below.
  home.activation.pointerTracking =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD /usr/bin/defaults write NSGlobalDomain com.apple.mouse.scaling -float 2
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
