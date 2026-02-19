#!/bin/sh

# Common navigation
alias ..='cd ..'
alias ...='cd ../..'

# Listing
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF --color=auto --group-directories-first'

# Git shortcuts
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# FZF shortcuts
alias f='fzf'
alias fe='_smooth_fzf'
