# Common packages shared across macOS and Linux
{
  # List of unfree packages that need explicit permission
  unfreePackages = [ 
    "terraform" 
    "claude-code"
  ];
  
  # Package list function - takes system and pkgs
  packages = system: pkgs: with pkgs; 
    let
      # macOS-specific packages
      darwinPackages = lib.optionals (lib.hasSuffix "darwin" system) [
      # add Darwin specific packages
      ];
    in
    [
      # Development tools
      emacs-nox
      mc
      tmux
      mosh
      wezterm
      git
      git-lfs
      starship 
      chezmoi
      age
      openconnect
      terraform
      k9s
      htop
      kubectl
      mutagen
      docker
      devpod
      code-claude 

      # Python stuff
      uv
      azure-cli
      awscli
      vpn-slice
      openvpn

      (python3.withPackages (python-pkgs: with python-pkgs; [
        # Add more Python packages as needed
      ]))
    ] ++ darwinPackages;
}

