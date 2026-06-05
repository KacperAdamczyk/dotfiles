{ pkgs, ... }:

{
  home.stateVersion = "26.05";

  # ============================================================================
  # Packages
  # ============================================================================

  home.packages = with pkgs; [
    # Nix language servers
    nil
    nixd

    # Container tools
    docker
    docker-compose
    podman-desktop

    # Fonts
    nerd-fonts.monaspace
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    # Editor
    neovim
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

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
        /opt/homebrew/bin/brew shellenv | source
        if command -q mise
            mise activate fish | source
        end
      '';
      functions.nhs = ''
        env NIX_CONFIG="access-tokens = github.com=(gh auth token)" \
          nh darwin switch $argv
      '';
    };
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
    jjui.enable = true;

    # Editors & AI
    opencode.enable = true;
    helix.enable = true;

    # Runtimes
    bun.enable = true;
    java.enable = true;

    # Tools
    ripgrep.enable = true;
    fd.enable = true;
  };

  services = {
    podman.enable = true;
  };
}
