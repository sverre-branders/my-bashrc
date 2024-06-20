csv() {
    column -s ',' -t "$1" | less -RS
}

tsv() {
    column -s $'\t' -t "$1" | less -RS
}

json() {
    jq '.' -C "$1" | less -RS
}

alias R='R --no-save --no-restore-data'
