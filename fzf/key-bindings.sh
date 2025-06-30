#! /bin/bash


if [[ $(type -P fzf) ]]; then

    export FZF_DEFAULT_OPTS="--border sharp --layout reverse --pointer ⮞ --marker '*' --prompt '' --color 'hl:2,marker:white,pointer:white,spinner:2,info:grey,gutter:-1,bg+:-1,hl+:2' --bind 'alt-j:down,alt-k:up,alt-J:preview-down,alt-K:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up,alt-q:abort'
    "

    # History
    __fzfcmd() {
        [[ -n "$TMUX_PANE" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "$FZF_TMUX_OPTS" ]]; } &&
            echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
    }

    __fzf_history__() {
        local output
        output=$(
            builtin fc -lnr -2147483648 |
            last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
          FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS +m --read0" $(__fzfcmd) --query "$READLINE_LINE"
        ) || return
        READLINE_LINE=${output#*$'\t'}
        if [[ -z "$READLINE_POINT" ]]; then
            echo "$READLINE_LINE"
        else
            READLINE_POINT=0x7fffffff
        fi
    }

    # Navigation
    _dir_fw_key="ctrl-g"
    _dir_bw_key="ctrl-b"
    _file_key="ctrl-f"

    __fzf_dir_fw__() {
        local query_dir="$1"
        local query="$2"

        local cmd="find -L \"${query_dir:-.}\" \
            -mindepth 1 -maxdepth 3 \
            -noleaf \( -name '.git' -o -name '__pycache__' \)\
            -prune -o -type d -print"

        local out
        mapfile -t out < <(
            {
                eval "$cmd"
                cat "$CD_HISTORY" 2>/dev/null
            } | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="$query" --preview="ls -a {}"
        )

        if [[ "${out[0]}" ]]; then
            case "${out[0]}" in
                "ctrl-c") return 0 ;;
                "$_dir_fw_key") __fzf_dir_fw__ "${out[1]}";;
                "$_dir_bw_key") __fzf_dir_bw__ "${out[1]}";;
                "$_file_key")   __fzf_file__ "${out[1]}";;
            esac
        else
            echo "cd \"${out[1]}\""
        fi
    }


    __fzf_dir_bw__() {
        local query_dir="${1:-.}"
        local query="$2"

        generate_directory_list() {
            local current_dir="$1"
            echo "$current_dir"
            local num=0

            pushd "$current_dir" > /dev/null || return 1
            while [[ "$PWD" != "/" ]]; do
                echo "$num: $PWD"
                num=$((num + 1))
                cd ..
            done
            echo "$num: /"
            popd > /dev/null || return 1
        }


        if [[ "${current_line[0]}" == "/" ]]; then
            directory_list="/"
        else
            directory_list=$(generate_directory_list "$query_dir")
        fi

        local out=$(
            echo -e "$directory_list" | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="$query" --preview="ls -a {}"
        )

        local key=$(head -1 <<< "$out")
        local dir=$(head -2 <<< "$out" | tail -1 | awk -F': ' '{print $2}')

        if [[ "$key" ]]; then
            case "$key" in
                "ctrl-c") return 0 ;;
                "$_dir_fw_key") __fzf_dir_fw__ "$dir";;
                "$_dir_bw_key") __fzf_dir_bw__ "$dir";;
                "$_file_key")   __fzf_file__ "$dir";;
            esac
        else
            echo "cd \"$dir\""
        fi
    }


    __fzf_file__() {
        local dir="${1:-.}"
        local query="${2:-}"

        local cmd="find -L \"$dir\" \
            -mindepth 1 -maxdepth 3 \
            -noleaf \( -name '.git' -o -name '__pycache__' \)\
            -prune -o -type f -print"

        local out
        mapfile -t out < <(eval "$cmd" | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="$query" --preview="head -n 30 {}") # TODO: better preview

        if [[ "${out[0]}" ]]; then
            case "${out[0]}" in
                "ctrl-c") return 0 ;;
                "$_dir_fw_key") __fzf_dir_fw__ "$(dirname ${out[1]})";;
                "$_dir_bw_key") __fzf_dir_bw__ "$(dirname ${out[1]})";;
                "$_file_key")   __fzf_file__ "${out[1]}";;
            esac
        else
            if [[ $(file --mime-type "${out[1]}") =~ "text" ]]; then
                echo "${EDITOR:-vim} \"${out[1]}\""
            else
                echo "xdg-open \"${out[1]}\" &>/dev/null &"
            fi
        fi
    }


    __fzf_nav__() {
        local current_line=($READLINE_LINE)

        if [ "$1" -eq 1 ]; then
            new_readline="$(__fzf_dir_fw__ ${current_line[0]:-.} ${current_line[1]})"
        elif [ "$1" -eq 2 ]; then
            new_readline="$(__fzf_dir_bw__ ${current_line[0]:-.} ${current_line[1]})"
        elif [ "$1" -eq 3 ]; then
            new_readline="$(__fzf_file__ ${current_line[0]:-.} ${current_line[1]})"
        fi

        READLINE_LINE="$new_readline"
        READLINE_POINT=${#READLINE_LINE}
    }


    if [[ $- == *i* ]]; then
        bind -m vi-insert -x '"\C-g":__fzf_nav__ 1 accept-line'
        bind -m vi-insert -x '"\C-b":__fzf_nav__ 2'
        bind -m vi-insert -x '"\C-f":__fzf_nav__ 3'
        bind -m vi-insert -x '"\C-r": __fzf_history__'
    fi
fi
