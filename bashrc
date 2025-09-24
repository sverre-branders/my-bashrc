export VISUAL=vim
export EDITOR="$VISUAL"

bashrc_path=$(realpath $HOME/.bashrc)
if [ -e "${bashrc_path%/bashrc}/config/.conda.sh" ]; then
    source "${bashrc_path%/bashrc}/config/.conda.sh"
fi
if [ -e "${bashrc_path%/bashrc}/config/.paths.sh" ]; then
    source "${bashrc_path%/bashrc}/config/.paths.sh"
fi

source "${bashrc_path%/bashrc}/config/ps1.sh"
source "${bashrc_path%/bashrc}/config/ssh_setup.sh"
source "${bashrc_path%/bashrc}/config/ls_colors.sh"
source "${bashrc_path%/bashrc}/config/alias_and_funcs.sh"

# fzf
source "${bashrc_path%/bashrc}/fzf/scripts/keep_cd_history.sh"
source "${bashrc_path%/bashrc}/fzf/bash-completions-fzf"
source "${bashrc_path%/bashrc}/fzf/key-bindings.sh"
source "${bashrc_path%/bashrc}/fzf/fzf_functions.sh"

umask 027
if [ -d "$HOME/.cargo/" ]; then
    . "$HOME/.cargo/env"
fi

set -o vi
bind -m vi-insert '"\e[3:5~": shell-kill-word'

if [ -x "$(command -v go)" ];then
    export PATH="$HOME/go/bin:$PATH"
fi
