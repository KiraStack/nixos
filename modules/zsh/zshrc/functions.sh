#!/bin/sh

# (fuzzy) Find a config file and open it in editor.
# I did not make this function,
# and absolutely do not understand how it works either (do not ask about it).
function _smooth_fzf
    set current_dir $PWD
    cd (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo ~/.config)
    set fname (fzf); or return
    $EDITOR $fname
    cd $current_dir
end


# Output most regularly used commands.
function toppy
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n 21
end

# Override default `cd`
# List directory contents after changing into it.
function cd
    builtin cd $argv; and ls --group-directories-first --color=auto -F
end
