#!/bin/sh
# Sources each (*).sh file found zsh.

for file in (find $HOME/.config/zsh -name "*.sh" 2>/dev/null)
    source $file
end
