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
  ____  _   _ _   _ ____  _   _    _    __  __ 
 / ___|| | | | | | | __ )| | | |  / \  |  \/  |
 \___ \| |_| | | | |  _ \| |_| | / _ \ | |\/| |
  ___) |  _  | |_| | |_) |  _  |/ ___ \| |  | |
 |____/|_| |_|\___/|____/|_| |_/_/   \_\_|  |_|
 
EOF
echo -e "${NC}"
echo -e "${YELLOW}           Welcome to Shubham (Shubham) v26.1${NC}"
echo -e "${CYAN}=================================================${NC}"
echo -e "${GREEN}          Panel Updater & Downgrader             ${NC}"
echo ""

# Check if Panel is installed
if [ ! -d "$PANEL_DIR" ] || [ ! -f "$PANEL_DIR/.env" ]; then
    echo -e "${RED}[ERROR] Pterodactyl Panel is not installed in $PANEL_DIR!${NC}"
    exit 1
fi

# Ask for the specific version
read -p "Enter Pterodactyl Version to Update/Downgrade (e.g., v1.11.7): " VERSION

echo -e "${GREEN}Starting process for version ${VERSION}...${NC}"

cd $PANEL_DIR

# 1. Put panel in maintenance mode
php artisan down

# 2. Clear old cache
rm -rf bootstrap/cache/*

# 3. Download the specific version to a file first
echo -e "${YELLOW}Downloading Panel files for ${VERSION}...${NC}"
curl -L -o panel.tar.gz https://github.com/pterodactyl/panel/releases/download/${VERSION}/panel.tar.gz

# 4. STRICT CHECK: Verify if the download is a valid archive
if ! tar -tzf panel.tar.gz > /dev/null 2>&1; then
    echo -e "${RED}[ERROR] Failed to download version ${VERSION}!${NC}"
    echo -e "${YELLOW}Mane rakho, version er aage obosshoi 'v' dite hobe (Example: v1.11.7).${NC}"
    echo -e "${YELLOW}Please check the version number and try again.${NC}"
    rm -f panel.tar.gz
    php artisan up
    exit 1
fi

# 5. Extract files if download was successful
echo -e "${GREEN}Download valid! Extracting files...${NC}"
tar -xzvf panel.tar.gz
rm -f panel.tar.gz

# 6. Set correct permissions
chmod -R 755 storage/* bootstrap/cache/

# 7. Update dependencies via Composer
echo -e "${YELLOW}Updating Composer dependencies...${NC}"
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

# 8. Clear caches & Migrate database
echo -e "${YELLOW}Clearing cache and migrating database...${NC}"
php artisan view:clear
php artisan config:clear
php artisan migrate --seed --force

# 9. Fix ownership & Restart Queue
chown -R www-data:www-data $PANEL_DIR/*
php artisan queue:restart

# 10. Take panel out of maintenance mode
php artisan up

echo -e "${CYAN}=================================================${NC}"
echo -e "${GREEN}Successfully updated/downgraded to ${VERSION}!${NC}"
echo -e "${CYAN}=================================================${NC}"
