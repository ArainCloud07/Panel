#!/bin/bash

# =========================================================
#                 SDGAMER CONFIGURATION
# =========================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Function: Professional SDGAMER Banner
function show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
  ____  _   _ _   _ ____  _   _    _    __  __ 
 / ___|| | | | | | | __ )| | | |  / \  |  \/  |
 \___ \| |_| | | | |  _ \| |_| | / _ \ | |\/| |
  ___) |  _  | |_| | |_) |  _  |/ ___ \| |  | |
 |____/|_| |_|\___/|____/|_| |_/_/   \_\_|  |_|
                                                       
EOF
    echo -e "${BLUE}    >>> POWERED BY Shubham HOSTING SOLUTIONS <<<    ${RESET}"
    echo -e "${YELLOW} ================================================== ${RESET}"
    echo ""
}

# Function: Pause/Wait for Enter
function wait_for_enter() {
    echo ""
    echo -e "${BLUE}--------------------------------------------------${RESET}"
    read -p " Press ENTER to return to Main Menu..."
}

# =========================================================
#                       MAIN MENU
# =========================================================

while true; do
    show_banner
    echo -e " ${GREEN}[1]${RESET} Install PufferPanel (Auto-Detect OS)"
    echo -e " ${RED}[2]${RESET} Exit"
    echo ""
    echo -n " Select an Option: "
    read option

    case $option in
        1)
            # START INSTALLATION
            show_banner
            echo -e "${YELLOW}[*] Checking System OS...${RESET}"
            sleep 1

            if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS=$ID
            else
                echo -e "${RED}[!] Error: Cannot detect OS.${RESET}"
                wait_for_enter
                continue
            fi

            echo -e "Detected OS: ${GREEN}${OS^^}${RESET}"
            echo ""
            sleep 1

            # --- FEDORA / RHEL / CENTOS LOGIC ---
            if [[ "$OS" == "fedora" || "$OS" == "rhel" || "$OS" == "centos" || "$OS" == "almalinux" ]]; then
                echo -e "${CYAN}>> Running DNF Update & Install...${RESET}"
                
                dnf update -y
                dnf upgrade -y
                dnf install wget fastfetch git -y
                
                echo -e "${CYAN}>> Adding PufferPanel Repo...${RESET}"
                curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.rpm.sh?any=true | bash
                
                echo -e "${CYAN}>> Installing Panel...${RESET}"
                dnf install pufferpanel -y

            # --- UBUNTU / DEBIAN LOGIC ---
            elif [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
                echo -e "${CYAN}>> Running APT Update & Install...${RESET}"
                
                apt update && apt upgrade -y
                apt install wget git -y
                # Fastfetch optional check
                apt install screenfetch -y
                apt install neofetch -y 2>/dev/null || echo "Fastfetch skipped"

                echo -e "${CYAN}>> Adding PufferPanel Repo...${RESET}"
                curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh\?any\=true | sudo bash
                
                echo -e "${CYAN}>> Installing Panel...${RESET}"
                sudo apt-get install -y pufferpanel
            
            else
                echo -e "${RED}[!] Unsupported OS: $OS${RESET}"
                wait_for_enter
                continue
            fi

            # --- COMMON FINAL STEPS ---
            echo ""
            echo -e "${YELLOW}>> Create Admin User:${RESET}"
            pufferpanel user add

            echo -e "${YELLOW}>> Enabling Service:${RESET}"
            systemctl enable --now pufferpanel
            systemctl start pufferpanel

            echo "Localhost:8080 (http)"
            echo -e "${GREEN}==================================================${RESET}"
            echo -e "${GREEN}         INSTALLATION COMPLETE - Shubham          ${RESET}"
            echo -e "${GREEN}==================================================${RESET}"
            
            # Installation shesh hole Enter chapte bolbe
            wait_for_enter
            ;;

        2)
            echo "Exiting..."
            exit 0
            ;;

        *)
            # Invalid Input Handling
            echo ""
            echo -e "${RED}[!] Invalid Option! Please try again.${RESET}"
            sleep 1.5
            ;;
    esac
done
