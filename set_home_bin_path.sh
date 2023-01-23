#!/bin/sh

# Setup ~/.bin
if [ -e ~/.bin ] || mkdir -p ~/.bin; then
cat << EOF | sudo tee /etc/profile.d/home_bin_path.sh > /dev/null
t=~/go/bin
[ -d "\$t" ] && [ ! -z "\${PATH##*\$t*}" ] && PATH=\$t:\$PATH;
t=~/.npm-global/bin
[ -d "\$t" ] && [ ! -z "\${PATH##*\$t*}" ] && PATH=\$t:\$PATH;
# [ -d "\$t" ] && [ ! -z "\${PATH##*\$t*}" ] && PATH=\$PATH:\$t;
t=~/.local/bin
[ -d "\$t" ] && [ ! -z "\${PATH##*\$t*}" ] && PATH=\$t:\$PATH;
t=~/.bin
[ -d "\$t" ] && [ ! -z "\${PATH##*\$t*}" ] && PATH=\$t:\$PATH;
export PATH
EOF
sudo chmod +x /etc/profile.d/home_bin_path.sh
fi

grep "/.profile" ~/.bashrc || {
 	echo >> ~/.bashrc;
 	echo '[ -f ~/.profile ] && . ~/.profile' >> ~/.bashrc;
}
