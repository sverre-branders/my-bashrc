
RESET="\[\033[00m\]"
fgWHITE="\[\033[1;38;5;254m\]"
fgSEC="\[\033[1;38;5;2m\]"
fgDARK_GREY="\[\033[38;5;239m\]"

bgDARK_GREY="\[\033[48;5;239m\]"
bgMAIN="\[\033[48;5;4m\]"
bgSEC="\[\033[48;5;2m\]"

parse_git_branch() {
  if [ -d "$(git rev-parse --git-dir 2>/dev/null)" ]; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    commit=$(git rev-parse --short HEAD)
    if [ -n "$branch" ]; then
      echo " [ $branch - $commit ] "
    else
      echo " [ $commit ] "
    fi
  else
    echo ''
  fi
}

parse_time() {
    echo " [ $(date +%T) ] "
}

parse_conda_env() {
  env_name=$(conda info --env | grep '^active environment' | awk '{print $4}')
  if [ -n "$env_name" ]; then
    echo " ($env_name)"
  else
    echo ""
  fi
}

separator() {
    echo -e $'\uE0B0'
}

# PS
export PS1="${fgWHITE}${bgSEC}\$(parse_git_branch)${bgDARK_GREY} \u@\h ${RESET}${bgDARK_GREY}[ \W ] ${RESET}${fgDARK_GREY}\$(separator)${RESET} \$(date +%T) ${fgWHITE}$ ${RESET}"
export PS2="${fgSEC}~${RESET} "

# SSH setup
SSH_ENV="$HOME/.ssh/ssh_env"
function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

