# Tools managed by Homebrew on both macOS and Linux.
# Fedora-provided tools are listed separately in packages-fedora.txt.
tap "heroku/brew"
tap "microsoft/apm"
tap "protonpass/tap"

# Trust only the specific third-party formulae used by this setup.
brew "protonpass/tap/pass-cli", trusted: true
brew "starship"
brew "lazygit"
brew "jj"
brew "jjui"
brew "tuicr"
brew "mise"
brew "bun"
brew "portless"
brew "herdr"
brew "opencode"
brew "heroku/brew/heroku", trusted: true
brew "microsoft/apm/apm", trusted: true
brew "hunk"

# On Fedora, install the equivalents manually from packages-fedora.txt.
# Other Linux distributions must supply these tools through their own packages.
if OS.mac?
  brew "chezmoi"
  brew "fish"
  brew "zoxide"
  brew "atuin"
  brew "direnv"
  brew "neovim"
  brew "helix"
  brew "git"
  brew "gh"
  brew "ripgrep"
  brew "fd"
  brew "jq"
  brew "imagemagick"

  # Linux containers use a separately configured native engine (see README).
  brew "docker"
  brew "docker-compose"
  brew "colima"

  # GUI apps and fonts: Homebrew casks are macOS-only.
  cask "claude-code@latest"
  cask "codex"
  cask "crisp"
  cask "ghostty"
  cask "grok-build"
  cask "homebrew-app"
  cask "font-monaspice-nerd-font"
  cask "font-fira-code-nerd-font"
  cask "font-jetbrains-mono-nerd-font"
end
