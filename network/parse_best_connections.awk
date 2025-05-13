BEGIN {
    FS="|"
    OFS="|"
}

{
    essid = $1
    match($4, /-?[0-9]+/, m)
    level=m[0] + 0

    if (!(essid in best) || level > best[essid]) {
        best[essid] = level
        best_line[essid] = $0
    }
}

END {
    for (e in best_line) {
        print best_line[e]
    }
}
