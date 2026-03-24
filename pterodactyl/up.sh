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
echo -e "${YELLOW}           Welcome to SKA HOST (SDGAMER) v11.8${NC}"
echo -e "${CYAN}=================================================${NC}"
echo -e "${GREEN}          Panel Updater & Downgrader             ${NC}"
echo ""

# Check if Panel is installed before attempting to update
if [ ! -d "$PANEL_DIR" ] || [ ! -f "$PANEL_DIR/.env" ]; then
    echo -e "${RED}[ERROR] Pterodactyl Panel is not installed in $PANEL_DIR!${NC}"
    echo -e "${YELLOW}Please install the panel first before running this update/downgrade script.${NC}"
    exit 1
fi

# Ask for the specific version
read -p "Enter Pterodactyl Version to Update/Downgrade (e.g., v1.11.7): " VERSION

echo -e "${GREEN}Starting Update/Downgrade process for version ${VERSION}...${NC}"

# Move to Panel Directory
cd $PANEL_DIR

# 1. Put panel in maintenance mode
php artisan down

# 2. Clear old cache to prevent download/extraction errors
rm -rf bootstrap/cache/*

# 3. Download and extract the specified version
echo -e "${YELLOW}Downloading Panel files for ${VERSION}...${NC}"
curl -L https://github.com/pterodactyl/panel/releases/download/${VERSION}/panel.tar.gz | tar -xzv

# 4. Set correct permissions
chmod -R 755 storage/* bootstrap/cache/

# 5. Update dependencies via Composer (with root fix)
echo -e "${YELLOW}Updating Composer dependencies...${NC}"
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

# 6. Clear caches & Migrate database
echo -e "${YELLOW}Clearing cache and migrating database...${NC}"
php artisan view:clear
php artisan config:clear
php artisan migrate --seed --force

# 7. Fix ownership & Restart Queue
chown -R www-data:www-data $PANEL_DIR/*
php artisan queue:restart

# 8. Take panel out of maintenance mode
php artisan up

echo -e "${CYAN}=================================================${NC}"
echo -e "${GREEN}Successfully updated/downgraded to ${VERSION}!${NC}"
echo -e "${CYAN}=================================================${NC}"
