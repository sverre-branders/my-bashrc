#! /bin/bash


_dir_fw_key="ctrl-g"
_dir_bw_key="alt-b"
_file_key="ctrl-f"


__fzf_dir_fw__() {
    local current_line=($READLINE_LINE)

    local cmd="find -L \"${current_line[0]:-.}\" \
        -mindepth 1 -maxdepth 3 \
        -noleaf \( -name '.git' -o -name '__pycache__' \)\
        -prune -o -type d -print"

    local out
    mapfile -t out < <(
        {
            eval "$cmd"
            cat "$CD_HISTORY" 2>/dev/null
        } | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="${current_line[1]}" --preview="ls -a {}"
    )

    if [[ "${out[0]}" ]]; then
        READLINE_LINE="${out[1]} ${current_line[1]}"
        READLINE_POINT=${#READLINE_LINE}
        case "${out[0]}" in
            "ctrl-c") return 0 ;;
            "$_dir_fw_key") __fzf_dir_fw__ ;;
            "$_dir_bw_key") __fzf_dir_bw__ ;;
            "$_file_key")   __fzf_file__ ;;
        esac
    fi

    READLINE_LINE="cd ${out[1]}"
    READLINE_POINT=${#READLINE_LINE}
}


__fzf_dir_bw__() {
    local current_line=($READLINE_LINE)

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
        directory_list=$(generate_directory_list "${current_line[0]}")
    fi

    local out
    mapfile -t out < <(
        echo -e "$directory_list" | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="${current_line[1]}" --preview="ls -a {}"
    )

    if [[ "${out[0]}" ]]; then
        # TODO: some weirdness because of currentline here when chaining
        READLINE_LINE="${out[1]} ${current_line[1]}"
        READLINE_POINT=${#READLINE_LINE}
        case "${out[0]}" in
            "ctrl-c") return 0 ;;
            "$_dir_fw_key") __fzf_dir_fw__ ;;
            "$_dir_bw_key") __fzf_dir_bw__ ;;
            "$_file_key")   __fzf_file__ ;;
        esac
    fi

    READLINE_LINE="cd ${out[1]}"
    READLINE_POINT=${#READLINE_LINE}
}

bind -m vi-insert -x '"\C-g":__fzf_dir_fw__'
bind -m vi-insert -x '"\eb":__fzf_dir_bw__'
