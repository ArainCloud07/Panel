#!/bin/bash

# Colors setup
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}"
cat << "EOF"
  ____  ____   ____    _    __  __ _____ ____  
 / ___||  _ \ / ___|  / \  |  \/  | ____|  _ \ 
 \___ \| | | | |  _  / _ \ | |\/| |  _| | |_) |
  ___) | |_| | |_| |/ ___ \| |  | | |___|  _ < 
 |____/|____/ \____/_/   \_\_|  |_|_____|_| \_\
 
EOF
echo -e "${NC}"
echo -e "${YELLOW}           Welcome to SKA HOST (SDGAMER)${NC}"
echo -e "${CYAN}=================================================${NC}"
echo ""


# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== SKA HOSTING Panel Installer & Updater ===${NC}"

# User Inputs
read -p "Enter Pterodactyl Version (e.g., v1.11.7): " VERSION
read -p "Enter your Cloudflare Domain (e.g., panel.sub.com): " FQDN

PANEL_DIR="/var/www/pterodactyl"

update_panel() {
    echo -e "${GREEN}Panel is already installed. Starting Update/Downgrade to ${VERSION}...${NC}"
    cd $PANEL_DIR
    
    # Turn on maintenance mode
    php artisan down
    
    # Download and extract specific version
    curl -L https://github.com/pterodactyl/panel/releases/download/${VERSION}/panel.tar.gz | tar -xzv
    
    # Set permissions
    chmod -R 755 storage/* bootstrap/cache/
    
    # Update dependencies
    composer install --no-dev --optimize-autoloader
    
    # Clear caches and run database updates
    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    
    # Fix ownership
    chown -R www-data:www-data $PANEL_DIR/*
    php artisan queue:restart
    
    # Turn off maintenance mode
    php artisan up
    echo -e "${GREEN}Successfully updated/downgraded to ${VERSION}!${NC}"
}

install_panel() {
    echo -e "${GREEN}Panel not found. Starting fresh installation for ${VERSION}...${NC}"

    # 1. Install System Dependencies (Ubuntu/Debian based)
    apt update -y
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    apt update -y
    apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server

    # Install Composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

    # 2. Database Setup
    DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    mysql -u root -e "CREATE USER IF NOT EXISTS 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS panel;"
    mysql -u root -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;"
    mysql -u root -e "FLUSH PRIVILEGES;"

    # 3. Download Panel Files
    mkdir -p $PANEL_DIR
    cd $PANEL_DIR
    curl -L https://github.com/pterodactyl/panel/releases/download/${VERSION}/panel.tar.gz | tar -xzv
    chmod -R 755 storage/* bootstrap/cache/

    # 4. Environment and Panel Setup
    cp .env.example .env
    composer install --no-dev --optimize-autoloader
    php artisan key:generate --force

    # Configure .env file
    sed -i "s|APP_URL=http://localhost|APP_URL=https://${FQDN}|g" .env
    sed -i "s/DB_PASSWORD=/DB_PASSWORD=${DB_PASSWORD}/g" .env

    # Setup Database Tables (No user creation here as requested)
    php artisan migrate --seed --force

    chown -R www-data:www-data $PANEL_DIR/*

    # 5. Setup Nginx (Configured for Cloudflare proxy)
    cat <<EOF > /etc/nginx/sites-available/pterodactyl.conf
server {
    listen 80;
    server_name ${FQDN};
    root /var/www/pterodactyl/public;
    index index.html index.htm index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/pterodactyl.error.log error;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-enabled/default
    systemctl restart nginx

    # 6. Cron and Queue Worker
    (crontab -l -u www-data 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -u www-data -

    cat <<EOF > /etc/systemd/system/pteroq.service
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl enable --now pteroq.service redis-server

    echo -e "${GREEN}Fresh installation completed! Panel should now be available at your domain.${NC}"
}

# Main Execution Logic
if [ -d "$PANEL_DIR" ] && [ -f "$PANEL_DIR/.env" ]; then
    # Update the Domain in .env just in case it changed
    sed -i "s|^APP_URL=.*|APP_URL=https://${FQDN}|g" $PANEL_DIR/.env
    update_panel
else
    install_panel
fi

echo -e "${GREEN}Process Finished!${NC}"
