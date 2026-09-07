# dotfiles

My macOS and Fedora setup, managed with [chezmoi](https://www.chezmoi.io/).
Homebrew installs shared CLI tools and macOS apps. Fedora packages are installed
manually. Helix is the default editor; Neovim is also installed.

## 1. Install prerequisites

Use **Bash** for the commands below (`bash` starts it from another shell).

**Fedora:**

```bash
sudo dnf group install development-tools
sudo dnf install gcc make procps-ng curl file git chezmoi \
  fish zoxide atuin direnv neovim helix gh ripgrep fd-find jq ImageMagick
```

Install Ghostty separately using its [Linux installation guide](https://ghostty.org/docs/install/binary#fedora).
See [packages-fedora.txt](packages-fedora.txt) for the package reference and
optional Podman packages. Other Linux distributions need equivalent packages.

**macOS:** install the Xcode Command Line Tools if needed, and wait for the
installation to finish:

```bash
xcode-select --install
```

## 2. Install Homebrew

Skip the installer if Homebrew is already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Enable it in this Bash session using the command for your machine:

```bash
# Fedora
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

# macOS — Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv bash)"

# macOS — Intel
eval "$(/usr/local/bin/brew shellenv bash)"
```

Run only the matching line, then check `brew --version`. After applying,
Fish will set up Homebrew automatically. See [Homebrew installation](https://docs.brew.sh/Installation)
if the installer reports a problem.

**macOS only:**

```bash
brew install chezmoi
```

## 3. Prepare your SSH key

Git and jj are configured to sign commits using `~/.ssh/id_ed25519`.
Choose one option before initializing chezmoi.

**Use an existing key from Proton Pass:**

```bash
brew install protonpass/tap/pass-cli
pass-cli login
pass-cli vault list
pass-cli item list --vault-name Personal --filter-type ssh-key --output json
```

Replace `Personal` with your vault name. Note the key's reference as
`pass://SHARE_ID/ITEM_ID` for the next step. If the key is not in Proton Pass yet,
see [key import instructions](docs/maintenance.md#containers-ssh-and-proton-pass).

**Use a local key:** keep your existing `~/.ssh/id_ed25519`, or generate one
if that file does not exist:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
```

Leave the Proton Pass reference blank in the next step.

## 4. Initialize, preview, and apply

```bash
chezmoi init KacperAdamczyk
```

Answer the machine-specific prompts:

- **`protonpass.sshKeyItem`:** your key reference, or blank for a local key.
- **`colima.drive` (macOS only):** blank for normal container storage, or an
  external drive path such as `/Volumes/Data`.

Then preview the non-secret changes and apply:

```bash
chezmoi --skip-secrets diff
chezmoi apply
```

Apply installs the Brewfile packages, writes the dotfiles, retrieves a missing
SSH key if configured, and installs Node/pnpm through mise. It never runs DNF.
If an installation fails, fix the reported issue and rerun `chezmoi apply`.

## 5. Set up GitHub and signing

```bash
gh auth login
```

Add `~/.ssh/id_ed25519.pub` to GitHub as a **signing key** (and as an
**authentication key** if using SSH for Git transport). For a newly generated
key, update `dot_config/git/allowed_signers` in the chezmoi source directory
with its public key and your email, then apply again.

**macOS:**

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

**Fedora:**

```bash
ssh-add ~/.ssh/id_ed25519
```

If Fedora reports that no agent is available, run `eval "$(ssh-agent -s)"`
in this Bash session and retry. For agent setup across logins, see the
[maintenance guide](docs/maintenance.md#containers-ssh-and-proton-pass).

## 6. Switch to Fish

Still in Bash, run the commands for your OS.

**Fedora:**

```bash
chsh -s /usr/bin/fish
```

**macOS:**

```bash
fish_path="$(brew --prefix)/bin/fish"
grep -qxF "$fish_path" /etc/shells || printf '%s\n' "$fish_path" | sudo tee -a /etc/shells
chsh -s "$fish_path"
```

Log out and back in, then open a terminal and check:

```fish
brew --version
mise ls --current
node --version
pnpm --version
```

The mise list should show no missing runtimes. Install a Nerd Font on Linux
if prompt symbols are missing. macOS fonts are included in the Brewfile.

## More guides

- [Maintenance, containers, SSH, and troubleshooting](docs/maintenance.md)
- [Fedora package reference](packages-fedora.txt)
- [Repository instructions for coding agents](AGENTS.md)
