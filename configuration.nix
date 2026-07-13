{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
      "com.apple.swipescrolldirection" = true;  # natural scroll direction
      "com.apple.trackpad.scaling" = 2.0;       # trackpad tracking speed
      # Mouse tracking speed has no typed nix-darwin option (unlike trackpad
      # scaling above), so it's set via home.activation.pointerTracking in
      # home.nix instead of here.
    };
    dock.autohide = true;
    dock.mru-spaces = false;             # don't auto-rearrange Spaces by recency
    dock.show-recents = false;           # no recent-apps section in the Dock
    dock.launchanim = false;             # no bounce on app launch
    dock."minimize-to-application" = false; # minimized windows get their own Dock icon
    WindowManager.StandardHideWidgets = true;    # hide widgets on desktop
    WindowManager.StageManagerHideWidgets = true; # hide widgets in Stage Manager
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    finder.AppleShowAllFiles = true;       # show hidden files
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    finder.FXDefaultSearchScope = "SCcf";  # search the current folder, not "This Mac"
    trackpad.Clicking = true;              # tap to click
    # Swipe between spaces with both three and four fingers. These only
    # conflict with three-finger drag (not enabled here), so both can be on
    # simultaneously - this matches System Settings' own default behavior.
    trackpad.TrackpadFourFingerHorizSwipeGesture = 2;
    trackpad.TrackpadThreeFingerHorizSwipeGesture = 2;
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;  # adopt the pre-existing /opt/homebrew instead of erroring
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";  # keep apps not listed here (protects existing installs)
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "fluxcd/tap"
      "minio/stable"
      "siderolabs/tap"
      "hashicorp/tap"
    ];
    brews = [
      "herdr"
      # core CLI & editor tools
      "bat" "eza" "gh" "htop" "tmux" "wget" "zoxide" "curl" "cmake" "make"
      "llvm" "boost" "thefuck" "pandoc" "graphviz" "imagemagick" "rsync"
      "diff-pdf" "sl" "watch" "gcc"  # zsh aliases g++/gcc pin to gcc's g++-15/gcc-15
      # cloud / infra / k8s / devops
      "awscli" "azure-cli" "oci-cli" "cilium-cli" "cloudflared" "fluxcd/tap/flux"
      "flyctl" "helmfile" "kubeconform" "kustomize" "minikube" "minio/stable/mc"
      "opentofu" "sops" "talhelper" "siderolabs/tap/talosctl" "virt-manager" "qemu"
      "ansible" "dive" "go-task" "hashicorp/tap/terraform"
      # language runtimes & databases
      "go" "node@22" "nvm" "maven" "postgresql@15" "postgresql@17" "mysql-client"
      "monetdb" "mongosh" "openvino" "pipx"
      # security / misc one-offs
      "age" "bitwarden-cli" "ghidra" "wireguard-tools" "openvpn" "gemini-cli"
      "hledger" "httpie" "hugo" "jemalloc" "netcat" "nmap" "subversion" "swaks"
      "telnet" "tio" "neofetch" "faiss" "gperftools" "armadillo" "bison"
      "cabextract" "makedepend" "parallel-hashmap" "patchelf" "robin-map" "spim"
      "aarch64-elf-gcc"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "bitwarden"
      "codex"
      "dbeaver-community"
      "font-noto-sans"
      "font-noto-sans-devanagari"
      "font-noto-serif"
      "font-noto-serif-devanagari"
      "ghidra"
      "google-chrome"
      "hiddenbar"
      "iterm2"
      "ngrok"
      "opencode-desktop"
      "orbstack"
      "stats"
      "temurin"
      "temurin@17"
      "visual-studio-code"
      "wave"
      "xquartz"
      "zed"
    ];
  };
}
