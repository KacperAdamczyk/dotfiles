if status is-interactive
    starship init fish | source
    zoxide init fish | source

    # set ZELLIJ_AUTO_ATTACH true
    # set ZELLIJ_AUTO_EXIT true
    # eval (zellij setup --generate-auto-start fish | string collect)
end

# uv
fish_add_path "/Users/kacper/.local/bin"
