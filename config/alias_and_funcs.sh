csv() {
    column -s ',' -t "$1" | less -RS
}

tsv() {
    column -s $'\t' -t "$1" | less -RS
}
