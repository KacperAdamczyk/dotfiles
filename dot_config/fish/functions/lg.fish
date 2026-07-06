function lg --wraps lazygit --description 'lazygit, cd to last repo/worktree on exit'
    set -f dir_file (mktemp -u)
    LAZYGIT_NEW_DIR_FILE=$dir_file lazygit $argv
    if test -s $dir_file
        cd (cat $dir_file)
        rm -f $dir_file
    end
end
