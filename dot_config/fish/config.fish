# Homebrew (Apple Silicon, Intel mac, Linux)
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    if test -x $brew_bin
        $brew_bin shellenv | source
        break
    end
end

# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Java (Homebrew's openjdk is keg-only)
if set -q HOMEBREW_PREFIX; and test -d $HOMEBREW_PREFIX/opt/openjdk/bin
    fish_add_path $HOMEBREW_PREFIX/opt/openjdk/bin
end

# Runtime version manager
if command -q mise
    mise activate fish | source
end

status is-interactive; and begin
    if command -q zoxide
        zoxide init fish | source
    end

    if test "$TERM" != dumb; and command -q starship
        starship init fish | source
    end
end
