function colima-start --description "Start colima with the external Data drive mounted read-write"
    if not test -d /Volumes/Data
        echo "colima-start: /Volumes/Data is not mounted — refusing to start" >&2
        echo "              (COLIMA_HOME would fall back to ~/.colima, a different VM)" >&2
        return 1
    end

    colima start --mount /Volumes/Data:w $argv
end
