#!/bin/bash

# Define Colors for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display the banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ________________________________________________  "
    echo " |                                                | "
    echo " |   SSSS  H   H U   U BBBB  H   H  AAA  M   M    | "
    echo " |  S      H   H U   U B   B H   H A   A MM MM    | "
    echo " |   SSS   HHHHH U   U BBBB  HHHHH AAAAA M M M    | "
    echo " |      S  H   H U   U B   B H   H A   A M   M    | "
    echo " |  SSSS   H   H  UUU  BBBB  H   H A   A M   M    | "
    echo " |________________________________________________| "
    echo " |            DARCO PANEL INSTALLER               | "
    echo " |________________________________________________| "
    echo -e "${NC}"
}

# Function to pause and wait for user input
pause() {
    read -n 1 -s -r -p "Press any key to continue..."
    echo ""
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root.${NC}" 
   echo "Please run: sudo bash $0"
   exit 1
fi

while true; do
    show_banner
    echo -e "${YELLOW}Select an option:${NC}"
    echo "1) Install Darco Panel"
    echo "2) Node Setup (Wings + Config)"
    echo "3) Start Panel (Existing)"
    echo "4) Start Node (Existing)"
    echo "0) Exit"
    echo ""
    read -p "Enter choice [0-4]: " choice

    case $choice in
        1)
            echo -e "${GREEN}>>> Installing Darco Panel...${NC}"
            # Utilizing the provided command
            bash <(curl -s https://raw.githubusercontent.com/ArainCloud07/Panel/refs/heads/main/Darco/Darco.panel)
            pause
            ;;
        2)
            echo -e "${GREEN}>>> Setting up Node/Wings...${NC}"
            # Installing wings script
            bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/Panel/main/Darco/wings)
            
            echo -e "${BLUE}Checking for 'node' directory...${NC}"
            if [ ! -d "node" ]; then
                mkdir -p node
                echo "Created 'node' directory."
            fi
            
            cd node
            
            echo -e "${YELLOW}-------------------------------------------------------${NC}"
            echo -e "${YELLOW}IMPORTANT: Please paste your Node/Wings configuration now.${NC}"
            echo -e "${YELLOW}-------------------------------------------------------${NC}"
            echo "Once you have pasted the configuration file (config.yml) or contents,"
            read -p "Press Enter to start the node..." confirm
            
            echo -e "${GREEN}Starting Node...${NC}"
            node .
            
            # Return to previous directory to keep script path valid
            cd .. 
            pause
            ;;
        3)
            echo -e "${GREEN}>>> Starting Panel...${NC}"
            if [ -d "panel" ]; then
                cd panel
                node .
                cd ..
            else
                echo -e "${RED}Error: 'panel' directory not found.${NC}"
            fi
            pause
            ;;
        4)
            echo -e "${GREEN}>>> Starting Node...${NC}"
            if [ -d "node" ]; then
                cd node
                node .
                cd ..
            else
                echo -e "${RED}Error: 'node' directory not found.${NC}"
            fi
            pause
            ;;
        0)
            echo -e "${RED}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 1
            ;;
    esac
done

