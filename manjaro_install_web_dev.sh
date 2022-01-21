#!/usr/bin/bash

#
# Auto-Install Tools for Web Development for Manjaro/ArchLinux
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

if [ -f "$_d_/duzun_root_CA.crt" ]; then
    sudo cp "$_d_/duzun_root_CA.crt" /etc/ca-certificates/trust-source/anchors/;
    sudo trust extract-compat
fi


$_i_ docker
$_i_ docker-compose

# Don't ask for sudo when running docker commands
sudo usermod -a -G docker "$(whoami)"

# Use OverlayFS2 - not sure it is necessary, as docker would start to use it by default
# [ -s /etc/docker/daemon.json ] || echo '{ "storage-driver": "overlay2" }' > /etc/docker/daemon.json

sudo systemctl enable docker
sudo systemctl start docker


$_i_ nginx
sudo systemctl enable nginx
sudo systemctl start nginx

$_i_ php-fpm
$_i_ php-intl
# $_i_ php-gd
# $_i_ php-xsl
# $_i_ php-odbc
# $_i_ php-tidy
# $_i_ php-mcrypt
# $_i_ php-imap
# $_i_ php-sqlite
# $_i_ php-gmagick
# $_i_ php-geoip
# # $_i_ php-mbstring
# $_i_ php-imagick

f=/usr/lib/systemd/system/php-fpm.service
sudo sed -i "s/PrivateTmp=true/PrivateTmp=false/g" $f;

# sudo systemctl enable php-fpm
# sudo systemctl start php-fpm

# alternative to nvm
curl https://get.volta.sh | bash

$_i_ nodejs
$_i_ npm

p=~/.npm-global
[ -e "$p" ] || mkdir $p
npm config set prefix '~/.npm-global'
# grep "/.npm-global/bin:" ~/.profile || echo "export PATH=~/.npm-global/bin:\$PATH" >> ~/.profile
# . ~/.profile
if [ ! -e "$p/lib/node_modules" ]; then
    mkdir -p "$p/lib/node_modules"
	mkdir -p "$p/bin"
	cp -R /usr/lib/node_modules/* "$p/lib/node_modules/"
	ln -sf "$p/lib/node_modules/npm/bin/npm-cli.js" "$p/bin/npm"
    [ -e ~/.bin ] && ln -sf "$p/lib/node_modules/npm/bin/npm-cli.js" ~/.bin/npm
fi;

npm i -g json nodemon pm2 markmon jshint lesshint

# See https://lsp.readthedocs.io/en/latest/
npm i -g    lsp-tsserver vue-language-server intelephense vscode-css-languageserver-bin \
            bash-language-server

unset p

# Some stuff required by some Sublime plugins:
$_i_ shellcheck
$_i_ pandoc
$_i_ global

# # Use container for MariaDB
# $_i_ mariadb
# # create mysql DB
# sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
# sudo systemctl enable mariadb
# sudo systemctl start mariadb
# sudo mysql_secure_installation


mkdir -p ~/Applications && wget -O ~/Applications/dbgate.AppImage https://github.com/dbgate/dbgate/releases/latest/download/dbgate-latest.AppImage && chmod +x ~/Applications/dbgate.AppImage

$_i_ sqlitebrowser
$_i_ mysql-workbench
$_i_ adminer
$_i_ phpmyadmin
cat << EOF | sudo tee /etc/nginx/sites-available/pma.lh > /dev/null
server {
    listen 80;
    listen 443 ssl http2;
    server_name     pma.lh;

    root    /usr/share/webapps/phpMyAdmin;
    index   index.php;

    location ~ \.php$ {
            try_files      \$uri =404;
            fastcgi_pass   unix:/run/php-fpm/php-fpm.sock;
            fastcgi_index  index.php;
            include        fastcgi.conf;
    }
}
EOF
echo 127.0.0.1 pma.lh | sudo tee -a /etc/hosts > /dev/null
# echo MySQL root pwd:
# mysql -u root -p < /usr/share/webapps/phpMyAdmin/sql/create_tables.sql
# mysql -u root -p << EOF
# GRANT USAGE ON mysql.* TO 'pma'@'localhost' IDENTIFIED BY 'pmapass';
# GRANT SELECT (
#     Host, User, Select_priv, Insert_priv, Update_priv, Delete_priv,
#     Create_priv, Drop_priv, Reload_priv, Shutdown_priv, Process_priv,
#     File_priv, Grant_priv, References_priv, Index_priv, Alter_priv,
#     Show_db_priv, Super_priv, Create_tmp_table_priv, Lock_tables_priv,
#     Execute_priv, Repl_slave_priv, Repl_client_priv
#     ) ON mysql.user TO 'pma'@'localhost';
# GRANT SELECT ON mysql.db TO 'pma'@'localhost';
# GRANT SELECT ON mysql.host TO 'pma'@'localhost';
# GRANT SELECT (Host, Db, User, Table_name, Table_priv, Column_priv)
#     ON mysql.tables_priv TO 'pma'@'localhost';
# GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost';
# EOF

if [ -z "$EDITOR" ]; then
    EDITOR=subl
fi

f=/etc/webapps/phpmyadmin/config.inc.php
if grep -q "\$cfg\['blowfish_secret'\] = '';" "$f"; then
    secret=$(head -c32 /dev/urandom | base64 | tr -d '=' | tr '+/' '-_')
    sed -i "s/\$cfg\['blowfish_secret'\] = '';/\$cfg['blowfish_secret'] = '$secret';/; s/\$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';/\$cfg['Servers'][\$i]['host'] = getenv('MYSQL_HOST') ?: 'localhost';\n\$port = getenv('MYSQL_PORT') and \$cfg['Servers'][\$i]['port'] = \$port;/" "$f"
fi

# sudo $EDITOR "$f"

$_i_ composer

# Install psysh
composer g require psy/psysh:@stable
# and PHP Docs for psysh
[ -e ~/.local/share/psysh ] || mkdir -p ~/.local/share/psysh
wget -O ~/.local/share/psysh/php_manual.sqlite https://psysh.org/manual/en/php_manual.sqlite
sudo sed -i 's/;extension=pdo_sqlite/extension=pdo_sqlite/' /etc/php/php.ini # required for PHP Docs

# $_i_ mailhog-bin # container
$_i_ logstalgia
# $_i_ sphinx # container
# $_i_ exim # ?
# $_i_ cntlm # NTLM proxy http://cntlm.sourceforge.net/

$_i_ ssllabs-scan
