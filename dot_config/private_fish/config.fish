if status is-interactive
    starship init fish | source
    zoxide init fish | source

    # set ZELLIJ_AUTO_ATTACH true
    # set ZELLIJ_AUTO_EXIT true
    # eval (zellij setup --generate-auto-start fish | string collect)
end

# uv
fish_add_path "/Users/kacper/.local/bin"

# pnpm
set -gx PNPM_HOME "/Users/kacper/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
