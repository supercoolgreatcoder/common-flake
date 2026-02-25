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

    # Helper function to create package bundle
    mkPackages = system:
      let
        pkgs = mkPkgs system;
      in
        pkgs.buildEnv {
          name = "nix-packages";
          paths = common.packages system pkgs;
          pathsToLink = [ "/bin" "/share" ];
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
  in
  {
    # macOS configuration
    # Install using: darwin-rebuild switch --flake ~/.config/nix#alamo
    darwinConfigurations."alamo" = nix-darwin.lib.darwinSystem {
      modules = [{
        environment.systemPackages = common.packages "aarch64-darwin" (mkPkgs "aarch64-darwin");
        nixpkgs.hostPlatform = "aarch64-darwin";
        nix.settings.experimental-features = "nix-command flakes";
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;
        nix.enable = false;
      }];
    };

    # Linux packages
    # Install using: nix profile install ~/.config/nix
    packages.x86_64-linux.default = mkPackages "x86_64-linux";
    packages.aarch64-linux.default = mkPackages "aarch64-linux";

    # Dev-only profile (k9s, git, mc)
    # Install using: nix profile install ~/.config/nix#dev
    packages.x86_64-linux.dev = mkDevPackages "x86_64-linux";
    packages.aarch64-linux.dev = mkDevPackages "aarch64-linux";
  };
}
