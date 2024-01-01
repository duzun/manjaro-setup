#!/bin/bash

#
# Auto-Install Apps and Tools for Manjaro/ArchLinux
#
# Resources:
# https://wiki.archlinux.org/index.php/Secure_Shell#Protection
#
# @author Dumitru Uzun (DUzun.me)
#

if ! pacman -Qi fakeroot > /dev/null; then
    sudo pacman -Sq base-devel
fi

if ! command -v yay > /dev/null; then
    sudo pacman -Sq yay
fi

_i_='yay -S --noconfirm'
_d_=$(dirname "$0");

# NumLock On at boot
sudo "$_d_/numlock_on_boot.sh";

# Setup ~/.bin
sudo "$_d_/set_home_bin_path.sh";

# Set some values in sysctl
sudo "$_d_/sysctl.sh";

# Enable BBR tcp_congestion_control
sudo "$_d_/enable_bbr.sh";

# The file /usr/bin/x-terminal-emulator is usually nonexistent on ArchLinux Systems, you have to link it manually.
[ -x /usr/bin/x-terminal-emulator ] || sudo ln -sT xterm /usr/bin/x-terminal-emulator

[ -x ./.bin/pacman-refresh-keys ] && ./.bin/pacman-refresh-keys

# Dropdown console
$_i_ guake
guake &

if ! ps -C rngd > /dev/null; then
    $_i_ rng-tools
    # echo RNGD_OPTS="-r /dev/urandom" | sudo tee /etc/conf.d/rngd
    sudo systemctl enable rngd
    sudo systemctl start rngd
fi

$_i_ dialog

$_i_ git
curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh > ~/.bash_git
grep "/.bash_git" ~/.bashrc || {
 	echo >> ~/.bashrc;
 	echo '[ -f ~/.bash_git ] && . ~/.bash_git' >> ~/.bashrc;
}

# Unlock id_rsa key with KWallet
f=~/.config/autostart-scripts/ssh-add.sh
if [ ! -s "$f" ] && [ -s "$_d_/autostart-scripts/ssh-add.sh" ];
then
    cat "$_d_/autostart-scripts/ssh-add.sh" > "$f"
    chmod +x "$f"
fi

# UI for systemctl
$_i_ systemd-kcm

# $_i_ redshift # not required any more, see "Night Mode" in settings
$_i_ synergy1-bin
# $_i_ dropbox
# $_i_ kde-servicemenus-dropbox

# Create an account at https://e.pcloud.com/#page=register&invite=BOUkZ4oWYRy
$_i_ pcloud-drive # pCloud drive client on Electron

$_i_ speedcrunch # advanced calculator
# $_i_ odrive-bin # Google Drive client on Electron
# $_i_ yandex-disk
# $_i_ yandex-disk-indicator
$_i_ brave-browser
# $_i_ google-chrome

# https://chrome.google.com/webstore/detail/plasma-integration/cimiefiiaegbelhefglklhhakcgmhkai
# https://addons.mozilla.org/en-US/firefox/addon/plasma-integration/
$_i_ plasma-browser-integration

$_i_ sshfs
$_i_ fuseiso
$_i_ ifuse

$_i_ cdemu-daemon
$_i_ cdemu-client

$_i_ autofs
sudo cp -R "$_d_"/autofs/* /etc/autofs/
sudo systemctl enable autofs
sudo systemctl start autofs

$_i_ etcher # write ISO to USB-Storage
$_i_ open-fuse-iso
$_i_ gparted # alternative to KDE Partition Manager
$_i_ kdiskmark # Measure storage read/write performance

$_i_ diffuse
$_i_ meld
$_i_ kdiff3
$_i_ terminator
$_i_ xorg-xkill # xkill any window app

$_i_ plasma5-applets-caffeine-plus # Prevents the desktop becoming idle in full-screen mode
$_i_ wmctrl # Window control utility
# $_i_ pamac-gtk # this is now the default GUI package manager
# $_i_ pamac-tray-appindicator # Tray icon using appindicator which feets better in KDE
$_i_ krita # photo editor
$_i_ blender # video editor
# $_i_ xnviewmp # photo viewer
$_i_ kodi # video player
$_i_ celluloid # video player
# $_i_ kodi-addon-stream
$_i_ rhythmbox # audio player
$_i_ rhythmbox-tray-icon # plugin for rhythmbox
$_i_ clementine # audio player

$_i_ qt-heif-image-plugin # Open HEIC images in Gwenview
# $_i_ qt5-avif-image-plugin # Open HEIC images in Gwenview, conflicts with kimageformats
$_i_ kdegraphics-thumbnailers
$_i_ heifthumbnailer
$_i_ raw-thumbnailer
$_i_ raw-thumbnailer-entry
$_i_ webp-thumbnailer
# $_i_ ffmpegthumbnailer-mp3
$_i_ exe-thumbnailer
$_i_ appimage-thumbnailer-git
# $_i_ jar-thumbnailer-git

# Install a hook for minidlna
_sed_=$(command -v sed)
cat << EOS | sudo tee /etc/pacman.d/hooks/minidlna-unjail-home.hook > /dev/null
[Trigger]
Type = Package
Target = minidlna
Operation = Install
Operation = Upgrade

[Action]
Description = Unjail home for MiniDLNA service
When = PostTransaction
Exec = $_sed_ -i 's/ProtectHome=on/ProtectHome=off/' /lib/systemd/system/minidlna.service
EOS
$_i_ minidlna # Media Server
# sed -i 's/ProtectHome=on/ProtectHome=off/' /lib/systemd/system/minidlna.service

# Security
$_i_ rkhunter
$_i_ fail2ban
$_i_ unhide

$_i_ clamav # antivirus
$_i_ clamtk # GUI for clamav

# Fast reboot
$_i_ dash
$_i_ kexec-tools

f=~/.bin/krbt
if [ ! -s "$f" ] && [ -s "$_d_/.bin/krbt" ];
then
    cat "$_d_/.bin/krbt" > "$f"
    chmod +x "$f"
fi

# # https://wiki.archlinux.org/index.php/PPTP_Client
# $_i_ pptpclient

# # Create MikroTel VPN connection and daemonize it
# [ -x "$_d_/setup_mikrotel_pptp.sh" ] && sudo "$_d_/setup_mikrotel_pptp.sh";

# Install Cronie (if missing) and setup /etc/cron.minutely folder
[ -d /etc/cron.minutely ] || sudo mkdir /etc/cron.minutely

cat << EOF | sudo tee /etc/cron.d/0minutely > /dev/null
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
*/1 * * * * root run-parts /etc/cron.minutely #Runs a cron job script every minute
EOF

if ! ps -C crond > /dev/null; then
    $_i_ cronie
    sudo systemctl enable cronie
    sudo systemctl start cronie
fi

$_i_ notepadqq # like notepad++

$_i_ vscodium-bin

# [ -d ~/.config/VSCodium/User ]
if [ -d ~/Dropbox/config/VSCodium/User/ ];
then
	ln -sf ~/Dropbox/config/VSCodium/User ~/.config/VSCodium/
fi


# $_i_ sublime-text-dev
# sudo ln -sf /opt/sublime_text_3/sublime_text /usr/bin/subl

# [ -d ~/.config/sublime-text-3/Packages/User ]
if [ -d ~/Dropbox/config/Sublime/User/ ];
then
	ln -sf ~/Dropbox/config/Sublime/User ~/.config/sublime-text-3/Packages/
fi

# File & Sync
$_i_ syncthing-gtk-python3

# Start syncthing delayed
f=~/.config/autostart-scripts/syncthing-delayed.sh
if [ ! -s "$f" ] && [ -s "$_d_/autostart-scripts/syncthing-delayed.sh" ];
then
    cat "$_d_/autostart-scripts/syncthing-delayed.sh" > "$f"
    chmod +x "$f"
fi

# systemctl enable --user syncthing
systemctl start --user syncthing


$_i_ freefilesync
$_i_ fslint

# $_i_ btsync-1.4
# sudo systemctl enable btsync
# sudo systemctl start btsync
# $_i_ btsync-gui
# google-chrome-stable http://localhost:8888 &

$_i_ qbittorrent

$_i_ gufw # GUI for ufw

# Like krunner
$_i_ rofi


# KDE VNC
$_i_ krfb
$_i_ krdc

# VNC
$_i_ tigervnc
# $_i_ tigervnc-viewer
$_i_ remmina

# Other Remote Desktop
$_i_ teamviewer
sudo systemctl enable teamviewerd


$_i_ telegram-desktop

$_i_ viber
# Start Viber and send it to the system tray
f=~/.config/autostart-scripts/viber-to-tray.sh
if [ ! -f "$f" ];
then
cat > "$f" << EOF
#!/bin/bash
viber StartMinimized &

sleep 3;
wid=\$(wmctrl -p -l | grep Viber | grep " \$! " | awk '{print \$1}') && \
wmctrl -i -c "\$wid"
# pidof /opt/viber/Viber

EOF
chmod +x "$f"

# Disable Viber autostart
f=~/.config/autostart/Viber.desktop
if [ -f "$f" ];
then
    if ! grep -q 'Hidden=true' -- "$f";
    then
        echo 'Hidden=true' >> "$f"
    fi
fi

fi


# $_i_ skypeforlinux-stable-bin
# cat > ~/.config/autostart/skypeforlinux.desktop << EOF
# [Desktop Entry]
# Name=Skype for Linux
# GenericName=Skype
# Exec=skypeforlinux
# Icon=skypeforlinux
# Terminal=false
# Type=Application
# Categories=Network;
# StartupNotify=false
# EOF

# SkypeForLinux doesn't use kwallet (yet?), but uses gnome-keyring instead
if $_i_ gnome-keyring;
then
    if command -v sddm > /dev/null;
    then
        if ! grep -lq pam_gnome_keyring.so -- /etc/pam.d/sddm;
        then
            # Add these lines to /etc/pam.d/sddm
            # -auth      optional     pam_gnome_keyring.so
            # -session   optional     pam_gnome_keyring.so auto_start

            t=-1;
            while read -r ln; do
                echo "$ln" | grep -q '^auth\s\+';
                s="$?"
                if [ "$s" -ne 0 ] && [ "$t" -eq 0 ]; then echo -e '-auth\t\toptional\tpam_gnome_keyring.so'; fi;
                t=$s;
                echo "$ln";
            done < /etc/pam.d/sddm > /tmp/etc_pam_sddm && \
            echo -e '-session\toptional\tpam_gnome_keyring.so\tauto_start' >> /tmp/etc_pam_sddm && \
            sudo mv -f /tmp/etc_pam_sddm /etc/pam.d/sddm
        fi
    fi

    git config --global  credential.helper gnome-keyring
    # git config --global  credential.modalprompt true
    $_i_ seahorse
fi


# Replace Yakuake with Guake
# You have to enable autostart in prefferences
cat > ~/.config/autostart/guake.desktop << EOF
[Desktop Entry]
Name=Guake Terminal
GenericName=Terminal
Comment=Use the command line in a Quake-like terminal
Exec=guake
Icon=guake
Terminal=false
Type=Application
Categories=GNOME;GTK;System;Utility;TerminalEmulator;
Encoding=UTF-8
StartupNotify=false
TryExec=guake
EOF

# Disable Yakuake autostart
f=~/.config/autostart/org.kde.yakuake.desktop
if [ -f "$f" ];
then
    if ! grep -q 'Hidden=true' -- "$f";
    then
        echo 'Hidden=true' >> "$f"
    fi
fi

# Ctrl+` opens Guake (global shortcut)
f=~/.config/kglobalshortcutsrc
if [ -f "$f" ];
then
    if ! grep -q '[guake.desktop]' -- "$f";
    then
		cat >> "$f" << EOF
[guake.desktop]
_k_friendly_name=Launch Guake Terminal
_launch=\\tMeta+\`,none,Launch Guake Terminal

EOF
    fi
fi


# Login screen on two displays
f=/usr/share/sddm/scripts/Xsetup
x=$(grep "xrandr --output" $f)
if [ -z "$x" ]; then
	x=$(xrandr --listmonitors | awk '{print $4}' | grep -v '^$')
	x1=$(echo "$x" | head -1)
	x2=$(echo "$x" | tail -1)
cat << EOF

xrandr --output $x1 --primary --left-of $x2
EOF
fi | sudo tee -a $f > /dev/null

$_i_ doublecmd-gtk2
$_i_ sddm-config-editor-git
$_i_ kazam
$_i_ flameshot
$_i_ obs-studio # screen recording/streaming
# $_i_ obs-nvfbc-git # requires https://github.com/keylase/nvidia-patch
$_i_ screenkey # show keystrokes on the screen
$_i_ kcolorchooser

#$_i_ winscp
$_i_ playonlinux

# if $_i_ crossover ;
# then
# 	$_i_ nss-mdns
# 	# On x64
#     $_i_ lib32-nss-mdns
# 	$_i_ lib32-sdl2
#     $_i_ lib32-vkd3d
# fi

$_i_ ttf-ms-fonts

# On x64
$_i_ lib32-libwbclient lib32-libxslt


$_i_ virtualbox virtualbox-host-dkms

$_i_ virt-manager virt-viewer qemu vde2 ebtables dnsmasq
sudo systemctl enable libvirtd
# sudo systemctl start libvirtd
echo "options kvm-intel nested=1" | tee /etc/modprobe.d/kvm-intel.conf

qemu-kvm

# If VMs doesn't start, try:
#   yay --noconfirm linux-headers
#   sudo modprobe vboxdrv

# depmod -a # Failed to start Load Kernel Modules

# Update virs signatures
sudo freshclam
