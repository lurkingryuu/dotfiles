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
    # Swipe between spaces with four fingers - Apple's factory default and the
    # conflict-free choice (three-finger swipes stay free for three-finger drag
    # and Look Up). System Settings treats these two as mutually exclusive, so we
    # pin four-finger on and three-finger horizontal off rather than leaving both
    # enabled (a UI-unreachable state) or leaving it to a manual toggle a rebuild
    # can knock out. Flip the two values to move the gesture to three fingers.
    trackpad.TrackpadFourFingerHorizSwipeGesture = 2;
    trackpad.TrackpadThreeFingerHorizSwipeGesture = 0;
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
    brews = [
      "herdr"
    ];
    casks = [
      "wezterm"
      "claude-code"
    ];
  };
}
