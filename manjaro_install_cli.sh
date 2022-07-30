#!/bin/sh

#
# Auto-Install Comand Line tools for Manjaro/ArchLinux
# @author Dumitru Uzun (DUzun.me)
#

if ! pacman -Qi fakeroot > /dev/null; then
    sudo pacman -Sq base-devel
fi

if ! command -v yay > /dev/null; then
    sudo pacman -Sq yay
fi

_i_='yay -S --noconfirm'
# _d_=$(dirname "$0");

$_i_ paru-bin # alternative to yaourt

$_i_ bat # like `cat`
$_i_ binwalk
$_i_ tokei # word count, code analysis

$_i_ pacui
$_i_ bash-completion
$_i_ vim # CLI Text Editor
$_i_ vifm # VI File Manager
$_i_ ccat # Syntax Highliting cat
$_i_ traceroute
$_i_ axel # Like wget, only in parallel
$_i_ jq # JSON
$_i_ htmlq # like jq, but for html
$_i_ htop
$_i_ i7z # CPU Info
$_i_ procs # aka ps
$_i_ debtap # Convert .deb package for Arch

# A collection of performance monitoring tools (iostat,isag,mpstat,pidstat,sadf,sar)
$_i_ sysstat
$_i_ ps_mem

# Google Drive CLI
$_i_ drive-bin # pull & push files
$_i_ google-drive-ocamlfuse-opam


# Network Monitoring - http://www.binarytides.com/linux-commands-monitor-network/
# $_i_ nmtui # UI to manage network settings
$_i_ nload
$_i_ nethogs
$_i_ bmon
$_i_ iftop
$_i_ iptraf-ng
$_i_ bind-tools
$_i_ rclone
$_i_ iputils # ping command
$_i_ traceroute


$_i_ ethtool # controll ethernet
$_i_ lshw # list hardware

# Network auditing
$_i_ nmap
$_i_ mtr

$_i_ ufw # firewall

# Modern HTTP benchmarking tool (aka ab): https://github.com/wg/wrk
$_i_ wrk

# a C library and a set of command-line programs providing a simple interface to inotify.
$_i_ inotify-tools

# # Sensors
# $_i_ lm_sensors
# $_i_ psensor
# $_i_ hddtemp

# Archivers
$_i_ zip
$_i_ brotli
$_i_ pigz # parallel gzip

# Disk
# $_i_ ncdu # like `du`
$_i_ borg # backup + compression + dedup
$_i_ borgmatic
$_i_ jdupes # jdupes -B -S -r /btrfs/mount/point
$_i_ duperemove # duperemove -dhr --hashfile=/var/cache/hdd.duphash /btrfs/mount/point
$_i_ compsize

$_i_ exa # aka ls

$_i_ broot # Fuzzy Search + tree + cd

$_i_ sox # CLI audio player

# For fun
$_i_ fortune-mod
$_i_ cowsay
$_i_ espeak # Text-2-Speach synthesizer
# $_i_ aview # Image to ASCII converter
