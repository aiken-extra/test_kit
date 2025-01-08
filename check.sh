#!/bin/bash

# PROJECT=$(pwd | rev | cut -d '/' -f1 | rev)
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Get optional arguments
MATCH_TEST=""
ENV="default"
while getopts "m:E:H" opt; do
    case $opt in
        m)
            MATCH_TEST="$OPTARG"
            ;;
        E)
            ENV="$OPTARG"
            ;;
        H)
            echo -e "${MAGENTA}Usage${RESET}: ${WHITE}$0${RESET} -m <MATCH_TEST> -E <ENV>"
            exit 0
            ;;
        *)
            ;;
    esac
done

# Get the Latest Block-time
echo -e "${MAGENTA}Getting${RESET} the latest ${WHITE}block time${RESET}:"
NOW=$(curl "https://api.koios.rest/api/v1/tip?select=block_time" | jq .[].block_time)
echo ""

# Print the Latest Block-time:
echo -e "${MAGENTA}Current${RESET} ${WHITE}block time${RESET}: ${NOW}000"
echo ""

# Configure `aiken.toml`
CONFIG=()
while read LINE; do
    if [[ "$LINE" == now* ]]; then
        CONFIG+=("now = ${NOW}000")
    else
        CONFIG+=("$LINE")
    fi
done < aiken.toml
printf "%s\n" "${CONFIG[@]}" > aiken.toml

# Run `aiken check``
echo -e "${MAGENTA}Running${RESET} ${WHITE}aiken check${RESET}:"
aiken c -m "${MATCH_TEST}" --env "${ENV}"
echo ""
