#!/bin/bash

# --- Colors for formatting ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Function: SDGAMER Banner ---
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ____  _   _ _   _ ____  _   _    _    __  __ "
    echo " / ___|| | | | | | | __ )| | | |  / \  |  \/  |"
    echo " \___ \| |_| | | | |  _ \| |_| | / _ \ | |\/| |"
    echo "  ___) |  _  | |_| | |_) |  _  |/ ___ \| |  | |"
    echo " |____/|_| |_|\___/|____/|_| |_/_/   \_\_|  |_|"
    echo -e "${NC}"
    echo -e "${YELLOW}       Welcome to Shubham Panel Manager${NC}"
    echo "=================================================="
}

# --- Function: Option 1 (Install with OS Detection) ---
install_panel() {
    echo -e "${YELLOW}Checking System OS...${NC}"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo -e "${RED}Cannot detect OS. /etc/os-release missing.${NC}"
        return
    fi

    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        echo -e "${GREEN}Detected Ubuntu/Debian.${NC} Running Hydra1..."
        bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/Panel/main/Hydra/Hydra1.sh)
    
    elif [[ "$OS" == "fedora" ]]; then
        echo -e "${GREEN}Detected Fedora.${NC} Running Hydra2..."
        bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/Panel/main/Hydra/Hydra2.sh)
    
    else
        echo -e "${RED}Unsupported OS Detected: $OS${NC}"
        echo "Please use Ubuntu, Debian, or Fedora."
    fi
    
    read -p "Press Enter to return to menu..."
}

# --- Function: Option 2 (Add Node) ---
add_node() {
    echo -e "${GREEN}Cloning HydraDAEMON...${NC}"
    git clone https://github.com/hydren-dev/HydraDAEMON
    
    if [ -d "HydraDAEMON" ]; then
        cd HydraDAEMON
        
        echo -e "${GREEN}Installing dependencies (npm install)...${NC}"
        npm install
        
        echo ""
        echo -e "${YELLOW}--------------------------------------------------${NC}"
        echo -e "${YELLOW}ACTION REQUIRED: Configure Node${NC}"
        echo -e "Please paste your configuration now (or edit the config file)."
        echo -e "Once you have finished configuring, press Enter to start the node."
        echo -e "${YELLOW}--------------------------------------------------${NC}"
        read -p "Press Enter AFTER you have pasted/saved your configuration..." key

        echo -e "${GREEN}Starting Node...${NC}"
        node .
    else
        echo -e "${RED}Error: Failed to download HydraDAEMON.${NC}"
    fi
    
    # Return to previous directory
    cd ..
    read -p "Press Enter to return to menu..."
}

# --- Function: Option 3 (Start Panel) ---
start_panel() {
    if [ -d "oversee-fixed" ]; then
        echo -e "${GREEN}Starting Panel (oversee-fixed)...${NC}"
        cd oversee-fixed
        node .
        
    else
        echo -e "${RED}Error: Directory 'oversee-fixed' not found.${NC}"
    fi
    read -p "Press Enter to return to menu..."
}

# --- Function: Option 4 (Start Node) ---
start_node() {
    if [ -d "HydraDAEMON" ]; then
        echo -e "${GREEN}Starting Node (HydraDAEMON)...${NC}"
        cd HydraDAEMON
        node .
        
    else
        echo -e "${RED}Error: Directory 'HydraDAEMON' not found.${NC}"
    fi
    read -p "Press Enter to return to menu..."
}

# --- Main Logic Loop ---
while true; do
    show_banner
    echo "1. Install Panel (Auto OS Detect)"
    echo "2. Add Node (Install & Config)"
    echo "3. Start Panel"
    echo "4. Start Node"
    echo "0. Exit"
    echo ""
    read -p "Select an option [0-4]: " choice

    case $choice in
        1) install_panel ;;
        2) add_node ;;
        3) start_panel ;;
        4) start_node ;;
        0) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}" ; sleep 1 ;;
    esac
done
