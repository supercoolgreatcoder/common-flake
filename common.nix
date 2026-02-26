# Common packages shared across macOS and Linux
{
  # List of unfree packages that need explicit permission
  unfreePackages = [
    "terraform"
    "claude-code"
  ];

  # Dev-only packages (minimal set)
  devPackages = system: pkgs: with pkgs; [
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
    vpn-slice
  ];

  # Alamo profile packages (macOS) - dev + ffmpeg
  darwinPackages = system: pkgs: with pkgs;
    (devPackages system pkgs) ++ [
      ffmpeg
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

      (python3.withPackages (python-pkgs: with python-pkgs; [
        # Add more Python packages as needed
      ]))
    ];
}

