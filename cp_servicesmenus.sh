#!/bin/sh

_f=~/.local/share/kservices5/ServiceMenus
_l=~/.kde4/share/kde4/services/ServiceMenus
[ -d "$_f" ] || mkdir "$_f"
[ -e "$_l" ] || ln -sf "$_f" "$_l"
sudo cp "$(dirname "$0")/ServiceMenus"/* "$_f"
sudo cp "$(dirname "$0")/ServiceMenus"/*.png /usr/share/icons/

kbuildsycoca5
