# sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/darwin
{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;

          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.config.allowUnfree = true;

          # Enable experimental features
          nix.settings.experimental-features = "nix-command flakes";

          # System packages
          environment.systemPackages = with pkgs; [
            vim
            git
          ];

          environment.shells = [
            pkgs.fish
          ];

          programs.fish.enable = true;

          # Setup user
          users.users.kacper = {
            home = "/Users/kacper";
            shell = pkgs.fish;
          };
        };
    in
    {
      darwinConfigurations."Kacpers-Mac-mini" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
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
