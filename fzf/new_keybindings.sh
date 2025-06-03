#! /bin/bash

if [[ $(type -P fzf) ]]; then

    # TODO: remove this from fzf/fzf_defaults.sh
    export FZF_DEFAULT_OPTS="--border sharp --layout reverse --pointer ⮞ --marker '*' --prompt '' --color 'hl:2,marker:white,pointer:white,spinner:2,info:grey,gutter:-1,bg+:-1,hl+:2' --bind 'alt-j:down,alt-k:up,alt-J:preview-down,alt-K:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up,alt-q:abort'
    "

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
            } | fzf --expect=alt-c,alt-b,ctrl-f,ctrl-c --query="$query"
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

        local out=$(
            generate_directory_list "$dir" | fzf --expect=alt-c,alt-b,ctrl-f,ctrl-c --query="$query"
        )

        local key=$(head -1 <<< "$out")
        local dir=$(head -2 <<< "$out" | tail -1 | awk -F': ' '{print $2}')
        echo "$key"
        echo "$dir"
    }


    if [[ $- == *i* ]]; then
        echo "INTERACTIVE"
    else
        echo "NOT INTERACTIVE"
    fi

    __fzf_dir_fw__ . network
    __fzf_dir_bw__ . 2
fi
