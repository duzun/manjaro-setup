#!/bin/sh

#
# Keep your eyes safe on cron
#
# @author Dumitru Uzun (DUzun.Me)
# @web https://gist.github.com/duzun/99bd0d1cba6c8ad1b5bf321c2689a257
#

_user=${USER:-$(whoami)}
_icon=$(find /usr/share/icons -type f -name '*eye*' | head -1)
_cron_file="/var/spool/cron/$_user"
_display=${DISPLAY:-':0.0'}
_dbus=$DBUS_SESSION_BUS_ADDRESS
_env="DBUS_SESSION_BUS_ADDRESS=$_dbus DISPLAY=$_display"
_notify=$(command -v notify-send)

if [ -z "$_icon" ]; then
    _icon="$(dirname "$0")/eye-64x64.png"
    cp -f -- "$_icon" ~/.local/share/icons && _icon=~/.local/share/icons/eye-64x64.png
fi

if [ ! -f "$_cron_file" ]; then
    sudo touch "$_cron_file" && sudo chown "$(whoami)" "$_cron_file"
fi

if grep -lq '# 20-20-20 rule -' "$_cron_file"; then
    echo '"20-20-20 rule" already in cron'
else
    echo 'Installing "20-20-20 rule"...'
    cat >> "$_cron_file" <<-EOS

# 20-20-20 rule - In the 20 minutes interval, keep your eyes away for 20 seconds & view other objects which are around 20 feet ~ 6m away
*/20 * * * * $_env $_notify -i "$_icon" "20 - 20 - 20" "Time to take rest. Keep your eye safe :)"
EOS
fi

if grep -lq '# 2h rule -' "$_cron_file"; then
    echo '"2h rule" already in cron'
else
    echo 'Installing "2h rule"...'
    cat >> "$_cron_file" <<-EOS

# 2h rule - In the 2 hours interval, stay away from computers for at least 2 minutes
01 */2 * * * $_env $_notify -i "$_icon" "2 hrs eye rest" "Time to take rest for 2 minutes. Keep your eye safe :)"
EOS
fi

if ! ps -C crond > /dev/null; then
    echo "Warning: It looks like you don't have crond running!"
fi
