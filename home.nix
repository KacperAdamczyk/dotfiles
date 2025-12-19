{ config, pkgs, ... }:

{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    nil
    nixd
    github-copilot-cli
    pnpm
    yarn
    fnm
    colima
    docker
  ];

  programs = {
    nh = {
      enable = true;
      flake = "/Users/kacper/.config/darwin";
    };
    claude-code.enable = true;
    home-manager.enable = true;
    fish = {
      enable = true;
      shellInit = ''
        /opt/homebrew/bin/brew shellenv | source
        fnm env --use-on-cd --shell fish | source
      '';
    };
    starship.enable = true;
    zoxide.enable = true;
    lazygit.enable = true;
    git = {
      enable = true;
      signing = {
        key = "~/.ssh/id_ed25519";
        format = "ssh";
        signByDefault = true;
      };
      settings = {
        user = {
          name = "Kacper Adamczyk";
          email = "kacper@admck.com";
        };
      };
    };
    gh.enable = true;
    neovim.enable = true;
  };

  home.file = {
  };

  home.sessionVariables = {
  };
}
