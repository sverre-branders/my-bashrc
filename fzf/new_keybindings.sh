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


    if [[ $- == *i* ]]; then
        bind -m vi-insert '"\ec": "eval $(echo -e \"$_dir_fw_key\\n.\" | __navigate_vi_cmd_mode__)\n"'
        bind -m vi-insert '"\eb": "eval $(echo -e \"$_dir_bw_key\\n.\" | __navigate_vi_cmd_mode__)\n"'
        bind -m vi-insert '"\C-f": "eval $(echo -e \"$_file_key\\n.\" | __navigate_vi_cmd_mode__)\n"'

        bind -m vi-insert -x '"\C-r": __fzf_history__'

        git-commit-show () {
            git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"  | \
                fzf --ansi --no-sort --reverse --tiebreak=index --preview \
                'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ $# -eq 0 ] || git show --color=always $1 ; }; f {}' \
                --bind "alt-j:down,alt-k:up,alt-J:preview-down,alt-K:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up,alt-q:abort
                        (grep -o '[a-f0-9]\{7\}' | head -1 |
                        xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                        {}
            FZF-EOF" --preview-window=right:60%
        }

        conda-activate-env () {
            conda activate "$(conda env list | grep -v '^#' | fzf | awk '{print $1}')"
        }

        if [[ $(type -P pactl) ]]; then
            audio-device() {
                selected_device=$(pactl list short sinks | awk '{print $2}' | fzf --prompt="Select Audio Device:")

                if [[ -n "$selected_device" ]]; then
                    pactl set-default-sink "$selected_device"
                    echo "Connected to $selected_device"
                else
                    return 1
                fi
            }
        fi

    fi
fi
