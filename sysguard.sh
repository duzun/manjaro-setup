#!/bin/bash

# Copy ./SysGuardTabs/* to ~/.local/share/ksysguard/
# See "SelectedSheets" in ~/.config/ksysguardrc

me=$(realpath "$0")
src="$(dirname "$me")/SysGuardTabs"
dest=~/.local/share/ksysguard/

if [ "$1" == "-l" ]; then
    for i in "$src"/*; do
        if [ -d "$i" ]; then
            echo "$(basename "$i")/";
        fi;
    done
    echo
    ( cd "$src" && ls *.sgrd )
    exit
fi

[ -n "$1" ] && src="$src/$1"

if [ ! -d "$src" ]; then
    >&2 echo "Source directory not found: '$src'"
    exit 1
fi

if [ ! -d "$dest" ]; then
    >&2 echo "Target directory not found: '$dest'"
    exit 1
fi

cp -- "$src"/*.sgrd "$dest"
