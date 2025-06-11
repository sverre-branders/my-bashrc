# Color Definitions
WHITE="15"
DARK="8"
MAIN="4"
SEC="12"

FG()
{
    case $1 in
        bWhite) echo -n "\[\033[1;38;5;${WHITE}m\]";;
        bMain) echo -n "\[\033[1;38;5;${MAIN}m\]";;
        bSec) echo -n "\[\033[1;38;5;${SEC}m\]";;
        bDark) echo -n "\[\033[1;38;5;${DARK}m\]";;
        white) echo -n "\[\033[0;38;5;${WHITE}m\]";;
        main) echo -n "\[\033[0;38;5;${MAIN}m\]";;
        sec) echo -n "\[\033[0;38;5;${SEC}m\]";;
        dark) echo -n "\[\033[0;38;5;${DARK}m\]";;
        *) echo -n "\[\033[0;39m\]";;
    esac
}

BG()
{
    case $1 in
        white) echo -n "\[\033[48;5;${WHITE}m\]";;
        main) echo -n "\[\033[48;5;${MAIN}m\]";;
        sec) echo -n "\[\033[48;5;${SEC}m\]";;
        dark) echo -n "\[\033[48;5;${DARK}m\]";;
        *) echo -n "\[\033[49m\]";;
    esac
}


USE_POWERLINE_SYMBOLS=1
SHOW_USER=0

RESET="$(echo -n -e "\[\033[0m\]")"
PL_CIRCLE_RIGHT=$(echo -e "\ue0b6")
PL_CIRCLE_LEFT=$(echo -e "\ue0b4")
PL_TRIANGLE_RIGHT=$(echo -e "\ue0b0")
PL_TRIANGLE_LEFT=$(echo -e "\ue0b2")
PL_ARROW_RIGHT=$(echo -e "\ue0b1")
PL_ARROW_LEFT=$(echo -e "\ue0b3")
CMD_SYMBOL=$(echo -e "\u2b9e")
CONDA_SYMBOL=$(echo -e "\ue715")
GIT_SYMBOL=$(echo -e "\ue725")


parse_git()
{
    # Get info
    local commit="$(git log --pretty=format:'%h' -n 1 2>/dev/null)"
    if [ -z "$commit" ]; then
      commit='no commits'
    fi
    local branch="$(git branch --show-current)"

    # Check whether on main branch
    default_branches=("main" "master")
    local is_default_branch=false
    for branch_name in "${default_branches[@]}"; do
        if [[ "$branch" == "$branch_name" ]]; then
            is_default_branch=true
            break
        fi
    done

    # Print Status
    local string=""
    if ! $is_default_branch; then
        string+="$branch-"
    fi

    string+="$commit"
    echo -n "$string"
}

parse_conda() {
    default_envs=("base" "python" "ePython")
    for env in "${default_envs[@]}"; do
        if [ "$CONDA_DEFAULT_ENV" = "$env" ]; then
            echo " $CONDA_SYMBOL "
            return
        fi
    done

    echo " $CONDA_SYMBOL $CONDA_DEFAULT_ENV "
}

parse_time() {
    echo -n "$(date +%T)"
}

set_powerline_prompt() {
    PS1=""
    # 
    if [ "$USE_POWERLINE_SYMBOLS" -eq 1 ]; then
        # PS1+="$(FG dark)$PL_CIRCLE_RIGHT$(FG bWhite)$(BG dark)"
        PS1+="$(FG bWhite)$(BG dark)"
        if [ "$SHOW_USER" -eq 1 ]; then
            PS1+=" \$USER $PL_ARROW_RIGHT"
        fi
        PS1+=" \W "

        # Check whether default environment
        if [ -n "$CONDA_DEFAULT_ENV" ]; then
            has_conda_env=true
        else
            has_conda_env=false
        fi

        if git rev-parse --is-inside-git-dir >/dev/null 2>&1; then
            is_git_dir=true
        else
            is_git_dir=false
        fi

        if $has_conda_enc || $is_git_dir; then
            PS1+="$(FG dark)$(BG main)$PL_TRIANGLE_RIGHT$(FG white)$(BG main)"
            if $has_conda_env; then
                PS1+="\$(parse_conda)"
            fi
            if $has_conda_env && $is_git_dir; then
                PS1+="$PL_ARROW_RIGHT"
            fi
            if $is_git_dir; then
                PS1+=" $GIT_SYMBOL \$(parse_git) "
            fi
            PS1+="${RESET}$(FG main)$PL_TRIANGLE_RIGHT"
        else
            PS1+="${RESET}$(FG dark)$PL_TRIANGLE_RIGHT"
        fi
        PS1+="$(FG dark)${CMD_SYMBOL}${RESET} "

        PS2="$(FG dark)${CMD_SYMBOL}${RESET} "
    fi
}

PROMPT_COMMAND=set_powerline_prompt
