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

# bibtex
get-bibtex () {
    if [[ ! $1 =~ ^https?:// ]] && [[ ! $1 =~ doi ]]; then
        link="https://doi.org/$1"
    else
        link=$1
    fi

    bibtex=$(curl -LH "Accept: application/x-bibtex" "$link")

    echo "$bibtex"
    echo "$bibtex" | xclip -selection clipboard
}

copy-citation () {
    bibtex-ls $1 | fzf --ansi | bibtex-cite -prefix="" | xclip -selection clipboard
}
