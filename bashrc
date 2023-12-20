export VISUAL=vim
export EDITOR="$VISUAL"

bashrc_path=$(realpath $HOME/.bashrc)
source "${bashrc_path%/bashrc}/config/ps1.sh"
source "${bashrc_path%/bashrc}/config/ssh_setup.sh"
source "${bashrc_path%/bashrc}/config/ls_colors.sh"
