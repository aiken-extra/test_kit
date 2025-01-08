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

# aiken build
echo -e "${MAGENTA}Running${RESET} ${WHITE}aiken build${RESET}:"
aiken b $1
echo "" # new line

# aiken blueprint & address
echo -e "${MAGENTA}Running${RESET} ${WHITE}aiken blueprint${RESET} & ${WHITE}aiken address${RESET}:"
aiken blueprint convert > ${PROJECT}.plutus
aiken address > ${PROJECT}.address
echo "" # new line

# aiken docs
if [ $# -eq 0 ]; then
    # README.md
    GLEAM_CODE=("\`\`\`gleam")
    AIKEN_CODE=("\`\`\`aiken")

    # README.md - aiken docs: preprocessing - replace ```gleam with ```aiken
    README=()
    while IFS= read -r LINE; do
        if [ "$LINE" == "$GLEAM_CODE" ]; then
            README+=("$AIKEN_CODE")
        else
            README+=("$LINE")
        fi
    done < README.md
    printf "%s\n" "${README[@]}" > README.md

    # Running `aiken docs`
    echo -e "${MAGENTA}Running${RESET} ${WHITE}aiken docs${RESET}:"
    aiken docs
    
    # README.md - aiken docs: postprocessing - replace ```aiken with ```gleam
    README=()
    while IFS= read -r LINE; do
        if [ "$LINE" == "$AIKEN_CODE" ]; then
            README+=("$GLEAM_CODE")
        else
            README+=("$LINE")
        fi
    done < README.md
    printf "%s\n" "${README[@]}" > README.md
fi

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
