# sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/darwin
# Kacper's nix-darwin system configuration
# Rebuild: darwin-rebuild switch --flake ~/.config/darwin
{
  description = "Kacper's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
    }:
    {
      darwinConfigurations."Kacpers-Mac-mini" = nix-darwin.lib.darwinSystem {
        modules = [
          # System configuration
          (
            { pkgs, ... }:
            {
              # System version
              system.configurationRevision = self.rev or self.dirtyRev or null;
              system.stateVersion = 6;

              # Platform configuration
              nixpkgs.hostPlatform = "aarch64-darwin";
              nixpkgs.config.allowUnfree = true;

              # Nix settings
              nix.settings.experimental-features = "nix-command flakes";

              # System packages
              environment.systemPackages = with pkgs; [
                vim
                git
              ];

              # Shell configuration
              environment.shells = [ pkgs.fish ];
              programs.fish.enable = true;

              # User configuration
              users.users.kacper = {
                home = "/Users/kacper";
                shell = pkgs.fish;
              };
            }
          )

          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.kacper = import ./home.nix;
            };
          }
        ];
      };
    };
}
