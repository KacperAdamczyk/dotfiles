# dotfiles

Cross-platform (macOS + Linux) dotfiles, managed with [chezmoi](https://www.chezmoi.io/).
macOS packages and shared CLI tools are installed with [Homebrew](https://brew.sh/)
from the [`Brewfile`](Brewfile). On Fedora, install distro packages manually using
[`packages-fedora.txt`](packages-fedora.txt) as a reference. No DNF installation
runs automatically. Other Linux distributions must supply equivalent packages.

## Layout

| Path | Purpose |
| --- | --- |
| `Brewfile` | Shared Homebrew tools and macOS-only formulae/casks |
| `packages-fedora.txt` | Manual Fedora package reference; never installed automatically |
| `run_onchange_before_install-packages.sh.tmpl` | Runs `brew bundle` automatically whenever the Brewfile changes |
| `dot_config/` | Files applied to `~/.config/` (fish, git, jj, starship, ghostty, mise) |
| `private_dot_ssh/` | The `~/.ssh/config` block, and the SSH key fetched from Proton Pass |
| `.chezmoiignore` | Files that live in the repo but are never applied to `$HOME` |

## Fresh system setup

### 1. Install Fedora prerequisites and Homebrew

On Fedora, review `packages-fedora.txt` and install the tools you want manually
with `sudo dnf install <package names>`. Install Fish and Helix before using the
shell configuration: it sets `EDITOR` and `VISUAL` to `hx`. Ghostty is already
RPM-installed on the current machine but was not in the cached available repo
metadata; a fresh machine may need the same third-party repository first.

Homebrew also needs the Fedora development tools:

```sh
sudo dnf group install development-tools
sudo dnf install procps-ng curl file git
```

See [Homebrew's Linux prerequisites](https://docs.brew.sh/Homebrew-on-Linux).
These commands are manual setup steps, not chezmoi hooks.

### Install Homebrew

macOS and Linux use the same installer:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

On Linux it installs to `/home/linuxbrew/.linuxbrew`; the installer prints an
`eval "$(... shellenv)"` line — run it once in the current shell so `brew` is on `PATH`.
The package hook fails if `brew` is missing from PATH. After installing it and
setting up the current shell environment, rerun `chezmoi apply`.

### 2. Install chezmoi and apply the dotfiles

Install chezmoi with `brew install chezmoi` on macOS or `sudo dnf install chezmoi`
on Fedora, then:

```sh
chezmoi init --apply KacperAdamczyk
```

This clones the repo to `~/.local/share/chezmoi`, runs `brew bundle` (installing
the entries enabled for your OS), and writes the managed configuration files.
It does not install anything from `packages-fedora.txt`.

If retrieving an SSH key from Proton Pass, install `protonpass/tap/pass-cli`
with Brew and run `pass-cli login` before applying: secret templates need the
CLI and an authenticated session. Leave the item reference blank to use a local key.

### 3. Make fish the login shell

On macOS (from a POSIX shell):

```sh
echo "$(brew --prefix)/bin/fish" | sudo tee -a /etc/shells
chsh -s "$(brew --prefix)/bin/fish"
```

On Fedora, after manually installing Fish:

```sh
chsh -s /usr/bin/fish
```

Log out and back in for the login-shell change to take effect.

### 4. macOS-only / Linux-only notes

- **Casks** (Ghostty, Claude Code, Codex, Nerd Fonts) only install on macOS.
  On Linux, install the equivalents through your distro's package manager:
  - Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`
  - Ghostty, Nerd Fonts: distro packages or upstream releases
- **Linux containers**: this machine already has Podman. For that workflow,
  install `podman` and optionally `podman-compose` manually, then use `podman`
  commands. Docker Engine is an alternative that needs its own installation and
  service setup. The Linux Brewfile installs neither Docker nor Compose, and
  chezmoi leaves `~/.docker/config.json` alone on Linux.
- **macOS containers**: Homebrew installs Docker CLI, Compose, and Colima,
  which provides the Linux VM. The drive prompt, Fish environment block, and
  `colima-start` helper are all macOS-only.
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
  - **On macOS**, if that key has a passphrase, hand it to the login keychain
    once per machine:

    ```sh
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    ```

    Nothing needs `ssh-add` after that, reboots included: `config.fish` runs
    `ssh-add --apple-load-keychain` on the first interactive shell, which
    re-adds every keychain-backed key to the agent.
  - **On Linux**, load the key into your session's SSH agent with
    `ssh-add ~/.ssh/id_ed25519` and check it with `ssh-add -l`. If no agent is
    available, start one for the current Fish session with
    `ssh-agent -c | source` first. This lasts for that agent's lifetime; for
    persistence across logins, configure your desktop/session agent separately.
    No Apple keychain commands run on Linux, and this repo does not start an
    agent automatically. Git and jj signing require the key before committing.
  - That macOS shell hook is the part that makes *signing* work, not the
    `~/.ssh/config` block. Git signs by shelling out to `ssh-keygen`, which
    never reads `ssh_config` and so cannot reach `UseKeychain` on its own — it
    needs the key already sitting in the agent, or it prompts for the
    passphrase on every single commit.
  - `~/.ssh/config` is maintained by a `modify_` script rather than managed as
    a whole file, because colima writes to it too: `colima start` appends an
    `Include` line for its own `ssh_config` (a fresh one per `COLIMA_HOME`,
    rather than replacing the previous). A fully managed file would be reverted
    on every `chezmoi apply` and re-appended on every `colima start`. The
    script rewrites only its own marked block and appends it last, so the
    host-specific settings colima includes above keep precedence —
    `ssh_config` uses the *first* value it obtains for each keyword.
    macOS-only: `UseKeychain` is an Apple keyword that ssh elsewhere rejects,
    so `.chezmoiignore` drops the file on Linux.
- **The key itself comes from Proton Pass**, so a new machine does not need the
  old one copied across by hand. Store it once, from a machine that has it:

  ```sh
  pass-cli login
  pass-cli vault list                                       # pick a vault
  pass-cli item create ssh-key import --vault-name Personal --password \
      --from-private-key ~/.ssh/id_ed25519 --title "SSH: id_ed25519"
  pass-cli item list --vault-name Personal --filter-type ssh-key --output json
  ```

  Both `create` and `list` need `--vault-name` (or `--share-id`); neither
  guesses a default. `--password` is for a passphrase-protected key, and the
  key is stored still encrypted — Proton holds the ciphertext, not the key.

  The import derives the item's `public_key` field from the key material and
  **drops the trailing comment**, which leaves `ssh-add -l` reporting "no
  comment". Put it back once, on the item:

  ```sh
  pass-cli item update --vault-name Personal --item-id <ITEM_ID> \
      --field "public_key=$(cat ~/.ssh/id_ed25519.pub)"
  ```

  The private key needs no such fix: its comment lives inside the key file,
  which round-trips byte for byte.

  Then set `protonpass.sshKeyItem` to `pass://SHARE_ID/ITEM_ID` (via
  `chezmoi init`, or by editing `~/.config/chezmoi/chezmoi.toml`), and
  `chezmoi apply` writes both halves of the key on any machine missing them.
  - The templates use chezmoi's `create_` prefix, which writes a file **only
    when it is absent**. So the fetch happens once, on a fresh machine: an
    existing key is never overwritten, machines that already have the key need
    no Proton session to run `chezmoi apply`, and `chezmoi diff` never prints
    private key material. To rotate, delete `~/.ssh/id_ed25519*` and apply.
  - The item reference lives in per-machine config rather than in this repo
    because the IDs belong to one Proton account. Leave it blank and the key
    templates are ignored entirely — same shape as `colima.drive`.
  - The passphrase is *not* in the vault, only the encrypted key file is. On a
    fresh machine you still need it for `ssh-add` (with `--apple-use-keychain` on macOS),
    so keep it somewhere in Proton Pass too.
- **Verifying signatures** needs `gpg.ssh.allowedSignersFile`, which points at
  `dot_config/git/allowed_signers` — a plain committed file, since public keys
  are not secret. Without it git cannot classify its own signatures and
  `git log --show-signature` errors out. Add a line per identity; the principal
  has to match the commit author, and `namespaces="git"` keeps the key from
  being trusted for anything beyond commit signatures.
- **jj signs separately from git.** It does not read `commit.gpgSign`, and its
  default is `signing.backend = "none"` — so every commit in this repo's
  history was written unsigned despite the git config asking for signatures.
  `dot_config/jj/config.toml` now sets the ssh backend with
  `behavior = "own"`. Check with `git log --format='%h %G? %GS'`: `G` is a good
  signature, `N` means none at all.
- **GitHub auth**: run `gh auth login` (git credentials go through `gh`).

## Day-to-day usage

```sh
chezmoi edit ~/.config/fish/config.fish   # edit a managed file
chezmoi diff                              # preview pending changes
chezmoi apply                             # apply configs + brew bundle (if Brewfile changed)
chezmoi cd                                # cd into this repo
```

Add a Homebrew package: add it to the `Brewfile`, then `chezmoi apply`.
Add a Fedora package: record it in `packages-fedora.txt` and install it manually.
Keep its Brew entry macOS-only to avoid requesting a second copy on Linux.
Homebrew may still install its own dependencies, even when DNF provides them.
Removing a Fedora entry does not uninstall the package.

Hunk now uses the core `hunk` formula. On a machine with the old tap version,
manually run `brew uninstall modem-dev/tap/hunk` before the next bundle run;
see [upstream migration guidance](https://github.com/modem-dev/hunk#install).
Adopt an existing dotfile: `chezmoi add ~/.config/<file>`.
Remove packages that are no longer in the Brewfile: `brew bundle cleanup --file "$(chezmoi source-path)/Brewfile"` (add `--force` to actually uninstall).
