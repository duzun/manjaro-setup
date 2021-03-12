#!/bin/bash

# Copy ./sysctl/* to /etc/sysctl.d/

me=$(realpath "$0")
dir="${me%.*}"
# b=$(basename "$0")
# x="${b##*.}"
# n="${b%.*}"

for i in "$dir"/*.conf; do
	b=$(basename "$i")
    echo -n "$b: ";
	cat "$i" | sudo tee "/etc/sysctl.d/$b"
done
