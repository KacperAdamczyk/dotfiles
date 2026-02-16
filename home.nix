{ config, pkgs, ... }:

{
  home.stateVersion = "26.05";

  # ============================================================================
  # Packages
  # ============================================================================

  home.packages = with pkgs; [
    # Nix language servers
    nil
    nixd

    # Node.js ecosystem
    nodejs_24
    fnm
    pnpm

    # Container tools
    colima
    docker
    podman-desktop

    # AI & CLI tools
    github-copilot-cli
    turso-cli
    postgresql

    # Fonts
    nerd-fonts.monaspace
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # ============================================================================
  # Programs
  # ============================================================================

  programs = {
    home-manager.enable = true;
    # Nix helper
    nh = {
      enable = true;
      flake = "/Users/kacper/.config/darwin";
    };

    # Shell & navigation
    fish = {
      enable = true;
      shellInit = ''
        fnm env --use-on-cd --shell fish | source
      '';
    };
    nushell.enable = true;
    starship.enable = true;
    zoxide.enable = true;

    # Version control
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
    lazygit.enable = true;
    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Kacper Adamczyk";
          email = "kacper@admck.com";
        };
      };
    };

    # Editors & AI
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    opencode.enable = true;
    claude-code.enable = true;

    # Runtimes
    bun.enable = true;
    java.enable = true;

    # Tools
    ripgrep.enable = true;
  };

  services = {
    podman.enable = true;
  };
}
