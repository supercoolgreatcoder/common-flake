{
  description = "Cross-platform nix configuration for macOS and Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    # Import common packages and config
    common = import ./common.nix;

    # Helper to create nixpkgs with unfree config
    mkPkgs = system: import nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) common.unfreePackages;
    };

    # Helper function to create dev-only package bundle
    mkDevPackages = system:
      let
        pkgs = mkPkgs system;
      in
        pkgs.buildEnv {
          name = "nix-dev-packages";
          paths = common.devPackages system pkgs;
          pathsToLink = [ "/bin" "/share" ];
        };

    # Helper function to create alamo/darwin package bundle (dev + ffmpeg)
    mkDarwinPackages = system:
      let
        pkgs = mkPkgs system;
      in
        pkgs.buildEnv {
          name = "nix-darwin-packages";
          paths = common.darwinPackages system pkgs;
          pathsToLink = [ "/bin" "/share" ];
        };

    # Helper function to create desktop package bundle
    mkDesktopPackages = system:
      let
        pkgs = mkPkgs system;
      in
        pkgs.buildEnv {
          name = "nix-desktop-packages";
          paths = common.desktopPackages system pkgs;
          pathsToLink = [ "/bin" "/share" ];
        };

    # Helper function to create nixos package bundle
    mkNixosPackages = system:
      let
        pkgs = mkPkgs system;
      in
        pkgs.buildEnv {
          name = "nix-nixos-packages";
          paths = common.nixosPackages system pkgs;
          pathsToLink = [ "/bin" "/share" ];
        };
  in
  {
    # macOS configuration (darwin profile: desktop + ffmpeg)
    # Install using: darwin-rebuild switch --flake ~/.config/nix#darwin
    darwinConfigurations."darwin" = nix-darwin.lib.darwinSystem {
      modules = [{
        environment.systemPackages = common.darwinPackages "aarch64-darwin" (mkPkgs "aarch64-darwin");
        nixpkgs.hostPlatform = "aarch64-darwin";
        nix.settings.experimental-features = "nix-command flakes";
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;
        nix.enable = false;
      }];
    };

    # Dev-only profile (k9s, git, mc, etc.)
    # Install using: nix profile install ~/.config/nix#dev
    packages.x86_64-linux.dev = mkDevPackages "x86_64-linux";
    packages.aarch64-linux.dev = mkDevPackages "aarch64-linux";

    # Desktop profile (dev + wezterm, docker, terraform, etc.)
    # Install using: nix profile install ~/.config/nix#desktop
    packages.x86_64-linux.desktop = mkDesktopPackages "x86_64-linux";
    packages.aarch64-linux.desktop = mkDesktopPackages "aarch64-linux";

    # NixOS profile (desktop + IDEs, browsers, and NixOS-specific tools)
    # Install using: nix profile install ~/.config/nix#nixos
    packages.x86_64-linux.nixos = mkNixosPackages "x86_64-linux";
    packages.aarch64-linux.nixos = mkNixosPackages "aarch64-linux";
  };
}
