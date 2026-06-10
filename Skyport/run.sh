#!/bin/bash

# Colors for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clear the screen
clear

# SDGAMER Banner
echo -e "${CYAN}=====================================================${NC}"
echo -e "${YELLOW}  ____  _   _ _   _ ____  _   _    _    __  __
 / ___|| | | | | | | __ )| | | |  / \  |  \/  |
 \___ \| |_| | | | |  _ \| |_| | / _ \ | |\/| |
  ___) |  _  | |_| | |_) |  _  |/ ___ \| |  | |
 |____/|_| |_|\___/|____/|_| |_/_/   \_\_|  |_| ${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo -e "${GREEN}      Skyport Panel & Wings Installer by Shubham    ${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo ""
echo -e "${YELLOW}Select an option:${NC}"
echo -e "1) ${GREEN}Install Skyport Panel${NC}"
echo -e "2) ${GREEN}Install Wings (Node)${NC}"
echo -e "3) ${GREEN}Relaunch Panel & Wings (PM2)${NC}"
echo -e "4) ${RED}Exit${NC}"
echo ""
read -p "Enter your choice: " choice

case $choice in
    1)
        echo -e "${CYAN}Starting Skyport Panel Installation...${NC}"
        sudo su -c "bash <(curl -s https://raw.githubusercontent.com/ArainCloud07/Panel/refs/heads/main/Skyport/Skyport.panel.sh)"
        ;;
    2)
        echo -e "${CYAN}Starting Wings/Node Installation...${NC}"
        sudo su -c "bash <(curl -s https://raw.githubusercontent.com/ArainCloud07/Panel/refs/heads/main/Skyport/Skyport.wings.sh"
        
        echo -e "${YELLOW}Now configuring node...${NC}"
        if [ -d "skyportd" ]; then
            cd skyportd
            echo -e "${RED}IMPORTANT:${NC} Please paste your Node Configuration Command below and press Enter:"
            # Opening a new shell to allow user to paste command or continue
            $SHELL
            
            echo -e "${GREEN}Starting Wings with PM2...${NC}"
            pm2 start .
        else
            echo -e "${RED}Error: skyportd directory not found. Installation might have failed.${NC}"
        fi
        ;;
    3)
        echo -e "${CYAN}Relaunching Panel & Wings...${NC}"
        pm2 start index
        pm2 start skyportd
        echo -e "${GREEN}Services restarted!${NC}"
        ;;
    4)
        echo -e "${RED}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option selected.${NC}"
        ;;
esac

