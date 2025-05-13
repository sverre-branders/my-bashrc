BEGIN {
    FS=" "
    OFS = "|"
}

/^\s+Cell\s+[0-9]+\s+-\s+Address:/ {
    address = $5
}

/^\s+Frequency:/ {
    sub(/^\s+Frequency:/,"")
    freq = $1 $2
}

/^\s+Quality=/ {
    sub("level=","")
    level=$3 $4
}

/^\s+ESSID:/ {
    sub("ESSID:","")
    gsub(/"|"/, "", $0)
    id=$1

    print id, address, freq, level
}
