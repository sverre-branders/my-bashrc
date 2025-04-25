# Color Definitions
WHITE="15"
DARK="8"
MAIN="4"
SEC="12"

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

HOST_NAME=$(hostnamectl hostname --pretty)
CMD_symbol=$(echo -n -e "\u2523")
TOP_symbol=$(echo -e "\u250F\u2501\u252B")
bSEP_symbol=$(echo -e "\u2503")
SEP_symbol=$(echo -e "\u2502")
BOTTOM_symbol=$(echo -e "\u2517\u252B")
RESET="$(echo -n -e "\[\033[0m\]")"

parse_git() {
    # Get info
    local commit="$(git log --pretty=format:'%h' -n 1 2>/dev/null)"
    if [ -z "$commit" ]; then
      commit='no commits'
    fi
    local branch="$(git branch --show-current)"

    # Print Status
    local string=""
    string+="$branch-$commit"
    string+=$modified
    echo -n "$string"
}

parse_time() {
    echo -n " [ $(date +%T) ] "
}

PS1=""
# First Line
PS1+="$(FG dark)$TOP_symbol"
PS1+="$(FG white)$(BG dark) $HOST_NAME $RESET"
PS1+="$(FG dark)$bSEP_symbol\w $RESET\n"

# Second Line
PS1+="$(FG dark)$BOTTOM_symbol$RESET"
PS1+="$(FG dark)$(date +%T)${RESET}" # Time stamp

if [ -n "$CONDA_DEFAULT_ENV" ]; then
    PS1+="$(FG main)${SEP_symbol}${CONDA_DEFAULT_ENV}${RESET}" # Conda environment
fi

if git rev-parse --is-inside-git-dir >/dev/null 2>&1; then
    PS1+="$(FG sec)${SEP_symbol}\$(parse_git)${RESET}" # Git status
fi

PS1+="$(FG dark)$CMD_symbol${RESET} "

