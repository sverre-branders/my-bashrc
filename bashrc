export VISUAL=vim
export EDITOR="$VISUAL"

bashrc_path=$(realpath $HOME/.bashrc)
if [ -e "${bashrc_path%/bashrc}/config/.conda.sh" ]; then
    source "${bashrc_path%/bashrc}/config/.conda.sh"
fi
source "${bashrc_path%/bashrc}/config/.paths.sh"

source "${bashrc_path%/bashrc}/config/ps1.sh"
source "${bashrc_path%/bashrc}/config/ssh_setup.sh"
source "${bashrc_path%/bashrc}/config/ls_colors.sh"
# fzf  
source "${bashrc_path%/bashrc}/fzf/bash-completions-fzf"
source "${bashrc_path%/bashrc}/fzf/key-bindings.bash"
