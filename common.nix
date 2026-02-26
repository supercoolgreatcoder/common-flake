# Common packages shared across macOS and Linux
rec {
  # List of unfree packages that need explicit permission
  unfreePackages = [
    "terraform"
    "claude-code"
    "pycharm"
    "rust-rover"
    "clion"
    "cursor"
    "slack"
  ];

  # Dev-only packages (minimal set)
  devPackages = system: pkgs: with pkgs; [
    wget
    curl
    jq
    k9s
    git
    mc
    emacs-nox
    tmux
    mosh
    git-lfs
    starship
    chezmoi
    age
    htop
    kubectl
    mutagen
    claude-code

    # Python stuff
    uv
    azure-cli
    awscli
    (python3.withPackages (python-pkgs: with python-pkgs; [
      # Add more Python packages as needed
    ]))
  ];

  # Desktop profile packages - dev + desktop tools
  desktopPackages = system: pkgs: with pkgs;
    let
      # macOS-specific packages
      darwinPackages = lib.optionals (lib.hasSuffix "darwin" system) [
      # add Darwin specific packages
      ];

      # Dev packages reference
      devPkgs = devPackages system pkgs;
    in
    [
      # Desktop tools
      wezterm
      openconnect
      terraform
      docker
      devpod
      openvpn
      vpn-slice
      ungoogled-chromium

      # IDEs
      code-cursor
      (jetbrains.pycharm.override {
        vmopts = ''
          -Xms128m
          -Xmx2048m
          -Dawt.toolkit.name=WLToolkit
        '';
      })
      (jetbrains.rust-rover.override {
        vmopts = ''
          -Xms128m
          -Xmx2048m
          -Dawt.toolkit.name=WLToolkit
        '';
      })
      (jetbrains.clion.override {
        vmopts = ''
          -Xms128m
          -Xmx2048m
          -Dawt.toolkit.name=WLToolkit
        '';
      })


    ] ++ devPkgs;

  # NixOS profile packages - desktop + additional NixOS-specific packages
  nixosPackages = system: pkgs: with pkgs;
    let
      # Desktop packages reference
      desktopPkgs = desktopPackages system pkgs;
    in
    [
      # System tools
      networkmanagerapplet
      # Desktop applications
      slack

      # Video and Wayland tools
      waypipe
      mesa-demos
      wev
    ] ++ desktopPkgs;

  # Alamo profile packages (macOS) - desktop + ffmpeg
  darwinPackages = system: pkgs:
    (desktopPackages system pkgs) ++ (with pkgs; [
      ffmpeg
    ]);


}

