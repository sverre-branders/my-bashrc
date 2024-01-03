# Color Definitions
WHITE="254"
DARK="239"
MAIN="4"
SEC="2"

FG() {
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

BG() {
    case $1 in
        white) echo -n "\[\033[48;5;${WHITE}m\]";;
        main) echo -n "\[\033[48;5;${MAIN}m\]";;
        sec) echo -n "\[\033[48;5;${SEC}m\]";;
        dark) echo -n "\[\033[48;5;${DARK}m\]";;
        *) echo -n "\[\033[49m\]";;
    esac
}

CMD_symbol=$(echo -n -e "\u2B9E")
SEP=$(echo -n -e "\uE0B0\u2B9E")
RESET="$(echo -n -e "\[\033[0m\]")"

parse_git() {
    # Check whether in git repo
    if ! git rev-parse --is-inside-git-dir >/dev/null 2>&1; then
        return
    fi

    # Get info
    local commit="$(git log --pretty=format:'%h' -n 1)"
    local branch="$(git branch --show-current)"

    # Print Status
    local string=""
    string+=" $branch - $commit "
    string+=$modified
    echo -n "$string"
}

parse_time() {
    echo -n " [ $(date +%T) ] "
}

parse_conda() {
    if [ ! -n "$CONDA_DEFAULT_ENV" ]; then
        return
    fi
    echo -n " $CONDA_DEFAULT_ENV "
}

PS1=""
PS1+="$(FG dark)$(BG white)\$(parse_conda)${RESET}" # Conda environment
PS1+="$(FG white)$(BG sec)$SEP${RESET}" # Separator

PS1+="$(FG dark)$(BG sec)\$(parse_git)${RESET}" # Git status
PS1+="$(FG sec)$(BG dark)$SEP${RESET}" # Separator

PS1+="$(FG white)$(BG dark) \W ${RESET}" # Directory
PS1+="$(FG dark)$SEP${RESET}" # Separator

PS1+="$(FG dark) $(date +%T) ${RESET}" # Time stamp
PS1+="$CMD_symbol "


