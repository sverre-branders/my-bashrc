bashrc_path=$(realpath $HOME/.bashrc)
source "${bashrc_path%/bashrc}/config/ps1.sh"
source "${bashrc_path%/bashrc}/config/ssh_setup.sh"
