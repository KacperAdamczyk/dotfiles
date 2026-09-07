# Repository instructions

This is a chezmoi source repository for macOS and Fedora. Read README.md for
fresh-machine setup and docs/maintenance.md for operational details.

## Package ownership

- Brewfile owns shared Homebrew tools and macOS-only formulae/casks.
- packages-fedora.txt is a manual reference. Do not add automatic DNF installs.
- Keep Fedora-provided tools macOS-only in Brewfile to avoid direct duplicates.
- Vim and Java were intentionally removed. Helix is the default editor;
  Neovim is also included.
- Keep third-party trust scoped to the formulae used, with `trusted: true`.

## Configuration and hooks

- Machine data belongs in ~/.config/chezmoi/chezmoi.toml, initialized by
  .chezmoi.toml.tmpl. Do not commit machine-specific drive paths or vault IDs.
- Gate Colima's prompt, Fish environment, and helper on macOS. Leave Linux
  SSH and Docker configuration unmanaged as specified by .chezmoiignore.
- The before hook tracks the Brewfile hash and runs brew bundle.
- The after hook tracks the mise config hash and installs global runtimes.
  Preserve ordering, project-config isolation, and nonzero failure exits.
- Fish initializes Homebrew and mise; Bash configuration is not managed.
- Keep documentation and reference files ignored by chezmoi so they are not
  copied into the destination home directory.

## Secrets and shared state

- SSH keys use create_ templates: preserve existing keys. Never capture private
  keys, tokens, or Docker auth in the repository or review output.
- On macOS, modify_ scripts preserve unrelated SSH and Docker configuration.
  Keep their preservation behavior when editing them.
- Git and jj sign independently. Preserve both signing configurations and the
  public allowed_signers file. Do not disable signing to work around an agent issue.

## Validation

- Run git diff --check for edits.
- For templates, render Linux and macOS cases, with empty and nonempty drive
  settings, and check shell syntax where relevant.
- Preview ordinary destination changes with chezmoi --skip-secrets diff.
  Use isolated configs and mocked commands to test install hooks without downloads.
- Keep README.md focused on a sequential new-machine setup. Put maintenance
  explanations in docs/maintenance.md and agent conventions here.
