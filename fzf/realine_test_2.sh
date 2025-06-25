#! /bin/bash


_dir_fw_key="ctrl-g"
_dir_bw_key="alt-b"
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
        echo "cd ${out[1]}"
    fi
}


__fzf_dir_bw__() {
    local query_dir="$1"
    local query="$2"

    generate_directory_list() {
        local current_dir="$1"
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
        echo "cd $dir"
    fi
}

__fzf_nav__() {
    local current_line=($READLINE_LINE)

    if [ "$1" -eq 1 ]; then
        new_readline="$(__fzf_dir_fw__ ${current_line[0]:-.} ${current_line[1]})"
    elif [ "$1" -eq 2 ]; then
        new_readline="$(__fzf_dir_bw__ ${current_line[0]:-.} ${current_line[1]})"
    fi

    READLINE_LINE="$new_readline"
    READLINE_POINT=${#READLINE_LINE}
}

bind -m vi-insert -x '"\C-g":__fzf_nav__ 1'
bind -m vi-insert -x '"\eb":__fzf_dir_bw__'
