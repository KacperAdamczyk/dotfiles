# dotfiles

Cross-platform (macOS + Linux) dotfiles, managed with [chezmoi](https://www.chezmoi.io/).
All packages are installed with [Homebrew](https://brew.sh/) from the [`Brewfile`](Brewfile).

## Layout

| Path | Purpose |
| --- | --- |
| `Brewfile` | All packages: taps, formulae, and (macOS-only) casks |
| `run_onchange_before_install-packages.sh.tmpl` | Runs `brew bundle` automatically whenever the Brewfile changes |
| `dot_config/` | Files applied to `~/.config/` (fish, git, jj, starship, ghostty, mise) |
| `.chezmoiignore` | Files that live in the repo but are never applied to `$HOME` |

## Fresh system setup

### 1. Install Homebrew

macOS and Linux use the same installer:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

On Linux it installs to `/home/linuxbrew/.linuxbrew`; the installer prints an
`eval "$(... shellenv)"` line — run it once in the current shell so `brew` is on `PATH`.
(On Linux you may first need build essentials: `sudo apt-get install build-essential curl file git`.)

### 2. Install chezmoi and apply the dotfiles

```sh
brew install chezmoi
chezmoi init --apply KacperAdamczyk
```

This clones the repo to `~/.local/share/chezmoi`, runs `brew bundle` (installing
everything in the Brewfile), and writes all the config files into `~/.config`.

### 3. Make fish the login shell

```sh
echo "$(brew --prefix)/bin/fish" | sudo tee -a /etc/shells
chsh -s "$(brew --prefix)/bin/fish"
```

### 4. macOS-only / Linux-only notes

- **Casks** (Ghostty, Claude Code, Codex, Nerd Fonts) only install on macOS.
  On Linux, install the equivalents through your distro's package manager:
  - Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`
  - Ghostty, Nerd Fonts: distro packages or upstream releases
- **Git signing** expects an SSH key at `~/.ssh/id_ed25519` — generate one with
  `ssh-keygen -t ed25519` and add it to GitHub as a *signing* key.
- **GitHub auth**: run `gh auth login` (git credentials go through `gh`).

## Day-to-day usage

```sh
chezmoi edit ~/.config/fish/config.fish   # edit a managed file
chezmoi diff                              # preview pending changes
chezmoi apply                             # apply configs + brew bundle (if Brewfile changed)
chezmoi cd                                # cd into this repo
```

Add a package: add it to the `Brewfile`, then `chezmoi apply`.
Adopt an existing dotfile: `chezmoi add ~/.config/<file>`.
Remove packages that are no longer in the Brewfile: `brew bundle cleanup --file "$(chezmoi source-path)/Brewfile"` (add `--force` to actually uninstall).
