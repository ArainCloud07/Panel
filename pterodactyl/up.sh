#!/bin/bash

# Colors setup
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PANEL_DIR="/var/www/pterodactyl"

# Banner
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
echo -e "${YELLOW}           Welcome to SKA HOST (SDGAMER) v10.1${NC}"
echo -e "${CYAN}=================================================${NC}"
echo -e "${GREEN}      Advanced Auto-Fix Installer & Updater      ${NC}"
echo ""

# Fix 1: Add Swap Memory to prevent Out-of-Memory Errors
if [ -z "$(swapon --show)" ]; then
    echo -e "${YELLOW}[Fix] Adding 2GB Swap Memory to prevent installation crashes...${NC}"
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    echo -e "${GREEN}Swap Memory added successfully!${NC}"
fi

update_panel() {
    echo -e "${GREEN}Starting Update/Downgrade setup for version ${VERSION}...${NC}"
    cd $PANEL_DIR
    php artisan down
    
    # Fix 2: Clear old cache before downloading
    rm -rf bootstrap/cache/*
    
    curl -L https://github.com/pterodactyl/panel/releases/download/${VERSION}/panel.tar.gz | tar -xzv
    chmod -R 755 storage/* bootstrap/cache/
    
    # Fix 3: Allow Composer as root without errors
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    
    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    chown -R www-data:www-data $PANEL_DIR/*
    php artisan queue:restart
    php artisan up
    echo -e "${GREEN}Successfully updated/downgraded to ${VERSION}!${NC}"
}

install_panel() {
    echo -e "${GREEN}Starting fresh installation & setup for ${VERSION}...${NC}"

    echo -e "${YELLOW}Installing System Dependencies...${NC}"
    apt update -y
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
    
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    apt update -y
    apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server

    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

    echo -e "${YELLOW}Setting up Database...${NC}"
    # Fix 4: Restart MariaDB to ensure it's fully running before creating DB
    systemctl restart mariadb
    sleep 3

    DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    mysql -u root -e "CREATE USER IF NOT EXISTS 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS panel;"
    mysql -u root -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;"
    mysql -u root -e "FLUSH PRIVILEGES;"

    echo -e "${YELLOW}Downloading Pterodactyl Panel...${NC}"
    mkdir -p $PANEL_DIR
    cd $PANEL_DIR
    curl -L https://github.com/pterodactyl/panel/releases/download/${VERSION}/panel.tar.gz | tar -xzv
    chmod -R 755 storage/* bootstrap/cache/
    cp .env.example .env

    echo -e "${YELLOW}Installing Composer Dependencies...${NC}"
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    
    php artisan key:generate --force

    sed -i "s|APP_URL=http://localhost|APP_URL=https://${FQDN}|g" .env
    sed -i "s/DB_PASSWORD=/DB_PASSWORD=${DB_PASSWORD}/g" .env

    echo -e "${YELLOW}Migrating Database...${NC}"
    php artisan migrate --seed --force
    chown -R www-data:www-data $PANEL_DIR/*

    echo -e "${YELLOW}Configuring Nginx...${NC}"
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

    echo -e "${GREEN}Fresh installation & setup completed! Panel is available at your domain.${NC}"
}

# Auto-Detection Logic
if [ -d "$PANEL_DIR" ] && [ -f "$PANEL_DIR/.env" ]; then
    echo -e "${GREEN}Pterodactyl Panel detected on this system!${NC}"
    read -p "Enter Pterodactyl Version to Update/Downgrade (e.g., v1.11.7): " VERSION
    update_panel
else
    echo -e "${YELLOW}No existing Panel found. Preparing for Fresh Installation.${NC}"
    read -p "Enter Pterodactyl Version (e.g., v1.11.7): " VERSION
    read -p "Enter your Cloudflare Domain (e.g., panel.sub.com): " FQDN
    install_panel
fi

echo -e "${CYAN}Process Finished Successfully!${NC}"
