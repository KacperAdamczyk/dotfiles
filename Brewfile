tap "heroku/brew"
tap "microsoft/apm"
tap "modem-dev/tap"
tap "protonpass/tap"

# Dotfiles management & secrets
brew "chezmoi"
brew "protonpass/tap/pass-cli"

# Shell & prompt
brew "fish"
brew "starship"
brew "zoxide"
brew "atuin"
brew "direnv"

# Editors
brew "neovim"
brew "vim"
brew "helix"

# Version control
brew "git"
brew "gh"
brew "lazygit"
brew "jj"
brew "jjui"
brew "tuicr"

# Runtimes & toolchains
brew "mise"
brew "bun"
brew "openjdk"

# Containers — colima provides the Linux VM the Docker CLI talks to on macOS
brew "docker"
brew "docker-compose"
if OS.mac?
  brew "colima"
end

# CLI tools
brew "ripgrep"
brew "fd"
brew "jq"
brew "imagemagick"
brew "portless"
brew "herdr"
brew "opencode"
brew "heroku/brew/heroku"
brew "microsoft/apm/apm"
brew "modem-dev/tap/hunk"

# GUI apps & fonts (macOS only — Homebrew casks don't exist on Linux)
if OS.mac?
  cask "claude-code@latest"
  cask "codex"
  cask "crisp"
  cask "ghostty"
  cask "grok-build"
  cask "font-monaspice-nerd-font"
  cask "font-fira-code-nerd-font"
  cask "font-jetbrains-mono-nerd-font"
end
