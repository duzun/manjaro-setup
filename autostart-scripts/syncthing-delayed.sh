#!/bin/bash

_start_time_=$(date +%s);

cpuload_percent() {
	local cpus
	local load
	cpus=$(lscpu | grep ^'CPU(s):' | cut -d':' -f 2)
	load=$(uptime | cut -d',' -f 3 | cut -d':' -f 2)
	bc -l <<< "$load / $cpus * 100" | cut -d'.' -f 1
}

get_folders() {
	cat ~/.config/syncthing/config.xml | grep '<folder ' | grep -v ' path="~"' | awk -F"path=" '{print $2}' | awk '{print $1}' | xargs -r -n1 echo | sed "s#^~#$HOME#"
}

folders_ok() {
	local folders 
	local i
	local p
	folders=$(get_folders) || return 1
	for i in ${folders[@]}; do
		p="$(realpath "$i")" || return 2
		if [ ! -d "$i/.stfolder" ]; then
			>&2 echo "No .stfolder in '$i'"
			return 3
		fi
		if ! touch "$i/.stfolder/w"; then
			>&2 echo "Not writeable '$i/.stfolder/'"
			return 4
		fi
		rm -f -- "$i/.stfolder/w"
	done
}

# cpuload_percent
sleep 10

while ! ps -C syncthing > /dev/null; do
	# cpuload_percent
	if [ "$(cpuload_percent)" -lt "29" ]; then
		if ! folders_ok; then
			e=$?
			>&2 echo "Error starting syncthing"
			exit $e
		fi

		echo "syncthing started after $(( $(date +%s) - _start_time_ ))s" >> /tmp/syncthing.log
		systemctl --user start syncthing
		break;
	fi
	sleep 3
done
