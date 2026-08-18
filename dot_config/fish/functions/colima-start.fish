function colima-start --description "Start colima with image storage and mounts on the external Data drive"
    set -l drive /Volumes/Data

    if not test -d $drive
        echo "colima-start: $drive is not mounted — refusing to start" >&2
        return 1
    end

    # Set COLIMA_HOME here as well as in config.fish, and create it: a shell
    # started before config.fish gained the export still autoloads this
    # function, and colima falls back to ~/.colima *silently* when the
    # variable is unset or its directory is missing — building the VM on the
    # boot SSD with no warning.
    set -gx COLIMA_HOME $drive/colima
    mkdir -p $COLIMA_HOME; or return 1

    colima start --mount $drive:w $argv
end
