#!/bin/sh

# NumLock On at boot
cat << EOF | sudo tee /etc/systemd/system/numlocklto8.service > /dev/null
[Unit]
Description=Switch on numlock from tty1 to tty8
[Service]
ExecStart=/bin/bash -c 'for tty in /dev/tty{1..8};do /usr/bin/setleds -D +num < \"\$tty\";done'
[Install]
WantedBy=multi-user.target

EOF

sudo systemctl enable numlocklto8

f=/etc/sddm.conf
x=$(grep "Numlock=" $f)
if [ -z "$x" ]; then
cat << EOF | sudo tee -a $f > /dev/null

[General]
Numlock=on
EOF
else
	sudo sed -i "s/$x/Numlock=on/g" $f;
fi
