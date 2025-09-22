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
alias conda_export='conda env export --no-builds | grep -v "^prefix: "'

# git
alias gis='git status -s'
alias gia='git add'
alias gic='git commit'

# rust
rdoc () {
    w3m $(rustup doc --path $1)
}
