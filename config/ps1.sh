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

parse_git_status() {
    if [ -d "$(git rev-parse --git-dir 2>/dev/null)" ]; then
        if [[ -z $(git status -s) ]]; then
            echo ''
        else
            echo " [+]"
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

export PS1="${fgWHITE}${bgSEC}\$(parse_git_status)\$(parse_git_branch)${fgSEC}${bgDARK_GREY}\$(separator)${RESET}${bgDARK_GREY} \u@\h ${fgWHITE}[ \W ] ${RESET}${fgDARK_GREY}\$(separator)${RESET} \$(date +%T) ${fgWHITE}$ ${RESET}"
export PS2="${fgSEC}~${RESET} "
