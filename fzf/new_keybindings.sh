#! /bin/bash

if [[ $(type -P fzf) ]]; then

    # TODO: remove this from fzf/fzf_defaults.sh
    export FZF_DEFAULT_OPTS="--border sharp --layout reverse --pointer ⮞ --marker '*' --prompt '' --color 'hl:2,marker:white,pointer:white,spinner:2,info:grey,gutter:-1,bg+:-1,hl+:2' --bind 'alt-j:down,alt-k:up,alt-J:preview-down,alt-K:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up,alt-q:abort'
    "

    _dir_fw_key="alt-c"
    _dir_bw_key="alt-b"
    _file_key="ctrl-f"

    __fzf_dir_fw__() {
        local dir="${1:-.}"
        local query="${2:-}"

        local cmd="find -L \"$dir\" \
            -mindepth 1 -maxdepth 3 \
            -noleaf \( -name '.git' -o -name '__pycache__' \)\
            -prune -o -type d -print"

        local out=$(
            {
                cat "$CD_HISTORY" 2>/dev/null
                eval "$cmd"
            } | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="$query"
        )

        echo "$out"
    }

    __fzf_dir_bw__() {
        local dir="${1:-.}"
        local query="${2:-}"

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

        if [[ "$dir" == "/" ]]; then
            out=$(echo "$dir" | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="$query")
        else
            out=$(
                generate_directory_list "$dir" | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="$query"
            )
        fi

        local key=$(head -1 <<< "$out")
        local dir=$(head -2 <<< "$out" | tail -1 | awk -F': ' '{print $2}')
        echo "$key"
        echo "$dir"
    }

    __fzf_file__() {
        local dir="${1:-.}"
        local query="${2:-}"

        local cmd="find -L \"$dir\" \
            -mindepth 1 -maxdepth 3 \
            -noleaf \( -name '.git' -o -name '__pycache__' \)\
            -prune -o -type f -print"

        local out=$(eval "$cmd" | fzf --expect=${_dir_fw_key},${_dir_bw_key},${_file_key},ctrl-c --query="$query")

        echo "$out"
    }

    __navigate_vi_cmd_mode__() {
        read -r key
        read -r path

        # echo "$key"
        # echo "$path"

        if [[ "$key" == "ctrl-c" ]]; then
            return 1

        elif [[ "$key" == "$_dir_fw_key" ]]; then
            out=$(__fzf_dir_fw__ "$path")
            echo "$out" | __navigate_vi_cmd_mode__

        elif [[ "$key" == "$_dir_bw_key" ]]; then
            if [[ -f "$path" ]]; then
                path=$(dirname "$path")
            fi
            out=$(__fzf_dir_bw__ "$path")
            echo "$out" | __navigate_vi_cmd_mode__

        elif [[ "$key" == "$_file_key" ]]; then
            out=$(__fzf_file__ "$path")
            echo "$out" | __navigate_vi_cmd_mode__

        else
            if [[ -d "$path" ]]; then
                echo "cd \"$path\""
            elif [[ -f "$path" ]]; then
                if [[ $(file --mime-type "$path") =~ "text" ]]; then
                    echo "${EDITOR:-vim} \"$path\""
                else
                    echo "xdg-open \"$path\" &>/dev/null &"
                fi
            fi
        fi
    }

    if [[ $- == *i* ]]; then
        bind -m vi-insert '"\ec": "eval $(echo -e \"$_dir_fw_key\\n.\" | __navigate_vi_cmd_mode__)\n"'
        bind -m vi-insert '"\eb": "eval $(echo -e \"$_dir_bw_key\\n.\" | __navigate_vi_cmd_mode__)\n"'
        bind -m vi-insert '"\C-f": "eval $(echo -e \"$_file_key\\n.\" | __navigate_vi_cmd_mode__)\n"'
    fi
fi
