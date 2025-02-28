#!/usr/env/bin bash
#
# wpinstall.sh
# WordPress Auto-Installer for Debian 12 / Ubuntu 24.04
#
# Author: Josh Madrone
# Date: 2025-02-28
# Version: 1.0
#
# The script supports both predefined variables and 
# interactive input. If environment variables (rootpass,
# dbname, dbuser, userpass, wpurl) are set before running
# the script, it will use those values. Otherwise, it will
# prompt the user interactively.

set -e

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update package list and install dependencies
echo "Updating system and installing required packages..."
apt update && apt upgrade -y
apt install -y apache2 mariadb-server php php-mysql libapache2-mod-php php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc php-zip unzip wget

# Enable required Apache modules
a2enmod rewrite
systemctl restart apache2

# Secure MySQL installation
mysql_secure_installation

# Allow predefined variables or interactive input
: "${rootpass:=$(read -p "Enter your MySQL root password: " REPLY && echo $REPLY)}"
: "${dbname:=$(read -p "Database name: " REPLY && echo $REPLY)}"
: "${dbuser:=$(read -p "Database username: " REPLY && echo $REPLY)}"
: "${userpass:=$(read -p "Enter a password for user $dbuser: " REPLY && echo $REPLY)}"

mysql -u root -p"$rootpass" <<EOF
CREATE DATABASE $dbname;
CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "New MySQL database successfully created."

# Allow predefined variables or interactive input for domain
: "${wpurl:=$(read -r -p "Enter your WordPress domain (e.g., mywebsite.com): " REPLY && echo $REPLY)}"

# Download and configure WordPress
wget -q -O latest.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz -C /var/www
mv /var/www/wordpress /var/www/$wpurl
rm latest.tar.gz

chown -R www-data:www-data /var/www/$wpurl
chmod -R 755 /var/www/$wpurl

cd /var/www/$wpurl
cp wp-config-sample.php wp-config.php
chmod 640 wp-config.php

sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$userpass/" wp-config.php

# Fetch and insert WP Authentication Keys and Salts
echo "Generating secure authentication keys and salts..."
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > wp-salts.txt

# Remove existing salts if present
sed -i '/AUTH_KEY/d' wp-config.php
sed -i '/SECURE_AUTH_KEY/d' wp-config.php
sed -i '/LOGGED_IN_KEY/d' wp-config.php
sed -i '/NONCE_KEY/d' wp-config.php
sed -i '/AUTH_SALT/d' wp-config.php
sed -i '/SECURE_AUTH_SALT/d' wp-config.php
sed -i '/LOGGED_IN_SALT/d' wp-config.php
sed -i '/NONCE_SALT/d' wp-config.php

# Insert new salts into wp-config.php
awk '/table_prefix/ {print; print ""; system("cat wp-salts.txt"); next}1' wp-config.php > wp-config-new.php
mv wp-config-new.php wp-config.php
rm wp-salts.txt

# Set up Apache virtual host
cat <<EOF > /etc/apache2/sites-available/$wpurl.conf
<VirtualHost *:80>
    ServerName $wpurl
    ServerAlias www.$wpurl
    DocumentRoot /var/www/$wpurl
    <Directory /var/www/$wpurl>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/$wpurl-error.log
    CustomLog \${APACHE_LOG_DIR}/$wpurl-access.log combined
</VirtualHost>
EOF

a2ensite $wpurl.conf
systemctl reload apache2

# Output success message
WPVER=$(grep "wp_version = " /var/www/$wpurl/wp-includes/version.php | awk -F\' '{print $2}')
echo -e "\nWordPress version $WPVER has been successfully installed!"
echo -en "Visit: http://$wpurl to complete the installation.\n"
