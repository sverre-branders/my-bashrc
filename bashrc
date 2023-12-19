parse_conda_env() {
  env_name=$(conda info --env | grep '^active environment' | awk '{print $4}')
  if [ -n "$env_name" ]; then
    echo " ($env_name)"
  else
    echo ""
  fi
}


# export PS1="$(parse_conda_env)\[\033[01;32m\]\u@\h\[\033[37m\]$(parse_git_branch)\[\033[00m\] $(date +%T): \[\033[01;34m\]\W\[\033[00m\]$ "
export PS1="\[\033[01;32m\]\u@\h\[\033[37m\] (\$(git symbolic-ref --short HEAD 2>/dev/null))\[\033[00m\] $(date +%T): \[\033[01;34m\]\W\[\033[00m\]$ "

eval "\$(ssh-agent -s)"
