#! /bin/bash

export CD_HISTORY="$HOME/.cdhistory"

write_to_hist() {
    local previous_history="$(grep -Fxv "$1" "$CD_HISTORY")"
    echo -e "$1\n$previous_history" | head -n 100 > "$CD_HISTORY"
}

cd() {
    builtin cd "$@" && write_to_hist "$PWD"
}
