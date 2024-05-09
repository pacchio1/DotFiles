#Rainbow welcome message
rainbow() {
    local string=$1
    local strlen=${#string}
    local i

    for (( i=0; i<strlen; i++ )); do
        local char="${string:$i:1}"
        local num=$(( (i * 10 / strlen) % 6 + 1 ))
        printf "\033[0;3${num}m${char}\033[0m"
    done
    printf "\n"
}

echo ""
rainbow "Welcome to my Raspberry"
echo ""