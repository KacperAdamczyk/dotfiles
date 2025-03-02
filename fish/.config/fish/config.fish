if status is-interactive
    # Commands to run in interactive sessions can go here
    switch (uname)
        case Linux
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        case Darwin
            eval "$(/opt/homebrew/bin/brew shellenv)"
    end

    if type -q starship
        starship init fish | source
    else
        echo "'starship' not found"
    end

    if type -q pnpm
        pnpm completion fish | source
    else
        echo "'pnpm' not found"
    end
end
