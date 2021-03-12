#!/bin/sh

# Create MikroTel VPN connection and daemonize it
#
# docs: https://wiki.archlinux.org/index.php/PPTP_Client
_pptp_name=MikroTel
_pptp_user="<username>"
_pptp_pass="<password>"

sudo pptpsetup --create $_pptp_name --server mikrotel.icasa.ru --username "$_pptp_user" --password "$_pptp_pass" --encrypt && \
sudo sed -ri 's/^require-mppe-128$/# require-mppe-128/' /etc/ppp/peers/$_pptp_name

cat << EOF | sudo tee /etc/systemd/system/mikrotel.service > /dev/null
[Unit]
Description=Connect to MiktoTel VPN over PPTP
[Service]
Type=oneshot
ExecStart=/usr/bin/pon $_pptp_name updetach persist ; /usr/bin/ip route add 192.168.0.0/24 dev ppp0 ;
ExecStop=/usr/bin/poff $_pptp_name
RemainAfterExit=true
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable mikrotel
sudo systemctl start mikrotel
