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
- **Containers**: the `docker` CLI installs everywhere, but on macOS it needs a
  Linux VM behind it — `colima` (macOS only) provides one.
  - Which drive holds the VM is **per-machine**, not baked into the repo. The
    answer lives in `~/.config/chezmoi/chezmoi.toml` as `colima.drive`, written
    by `chezmoi init` from `.chezmoi.toml.tmpl` and never committed here.
    Leave it blank and the whole colima block drops out of `config.fish`, the
    `colima-start` function is not installed at all, and colima uses its
    default `~/.colima` — so a machine with no external drive gets a working
    setup rather than a broken path. Change drives later with
    `chezmoi init` after clearing the value, or by editing that file.
  - Where a drive *is* configured, `COLIMA_HOME` points at `<drive>/colima`, so
    the VM's disk image — and therefore every container image layer, volume and
    build cache — lives there instead of on the boot disk. The export is
    guarded on the drive being mounted; without it colima falls back to
    `~/.colima`, which is a *separate, empty* VM rather than an error.
  - Start it with the `colima-start` function, which mounts the configured
    drive read-write into the VM so containers can reach files there, and
    refuses to run when it is absent.
  - **Do not use plain `colima start`.** Two traps: the drive is not mounted
    inside the VM without `--mount`, and colima falls back to `~/.colima`
    *silently* when `$COLIMA_HOME` does not exist yet — building the VM on the
    boot disk with no warning. `colima-start` creates the directory first so
    that fallback cannot trigger.
  - Colima switches the docker CLI to its own context on start, so no manual
    `docker context use` is needed.
  - **Unplug the drive only after `colima stop`.** Yanking it while the VM is
    running can corrupt the disk image, and nothing in this repo can guard
    against that.
  - Colima's own `colima.yaml` lives under `$COLIMA_HOME` and is deliberately
    *not* managed here — it is per-machine state tied to a specific drive.
  - `~/.docker/config.json` is managed by a `modify_` script that only registers
    Homebrew's `cli-plugins` dir (so `docker compose` resolves); `auths` and
    `currentContext` are read from the existing file and passed through, so
    credentials never enter this repo.
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
