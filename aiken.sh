#!/bin/bash
PROJECT=$(pwd | rev | cut -d '/' -f1 | rev)
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
RESET='\033[0m'

# aiken format
aiken fmt

# aiken check
echo -e "${MAGENTA}Running${RESET} ${WHITE}aiken check${RESET}:"
aiken c 2>&1 | tee ${PROJECT}.tests
echo "" # new line

# aiken docs
# Running `aiken docs`
echo -e "${MAGENTA}Running${RESET} ${WHITE}aiken docs${RESET}:"
aiken docs

# .gitignore
GITIGNORE=()
GITIGNORE+=("*.tests")
GITIGNORE+=("*.plutus")
GITIGNORE+=("*.address")
while IFS= read -r LINE; do
    if [ "$LINE" == "docs/" ]; then
        GITIGNORE+=("# docs/")
    elif [ "$LINE" != "*.tests" ] &&
         [ "$LINE" != "*.plutus" ] &&
         [ "$LINE" != "*.address" ]; then
        GITIGNORE+=("$LINE")
    fi
done < .gitignore
printf "%s\n" "${GITIGNORE[@]}" > .gitignore
