#!/bin/bash

# Colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Original ASCII Art for MythicalDash
show_header() {
    clear
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}    __  __       _   _               _     _____   ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   |  \/  |     | | | |             | |   |  __ \  ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   | \  / |_   _| |_| |__   ___   __| |___| |  | | ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   | |\/| | | | | __| '_ \ / _ \ / _\` / __| |  | | ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   | |  | | |_| | |_| | | | (_) | (_| \__ \ |__| | ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   |_|  |_|\__,_|\__|_| |_|\___/ \__,_|___/_____/  ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╠══════════════════════════════════════════════════╣${NC}"
    echo -e "${MAGENTA}║${NC}${BOLD}            D A S H B O A R D   M A N A G E R        ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

while true; do
    show_header
    
    # Menu Options
    echo -e "${PURPLE}┌────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}│${NC} ${GREEN}🚀${NC} ${BOLD}1.${NC} Install                 ${PURPLE}│${NC}"
    echo -e "${PURPLE}│${NC} ${YELLOW}🔄${NC} ${BOLD}2.${NC} Update                  ${PURPLE}│${NC}"
    echo -e "${PURPLE}│${NC} ${RED}🗑️${NC} ${BOLD}3.${NC} Uninstall                ${PURPLE}│${NC}"
    echo -e "${PURPLE}│${NC} ${BLUE}🚪${NC} ${BOLD}4.${NC} Switch to SDGAMER       ${PURPLE}│${NC}"
    echo -e "${PURPLE}├────────────────────────────────────────────────┤${NC}"
    echo -e "${PURPLE}│${NC} ${CYAN}📊${NC} Version: 3.2.3 | By: Shubham                ${PURPLE}│${NC}"
    echo -e "${PURPLE}└────────────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "$(echo -e "${YELLOW}🎯 Select option [1-4]:${NC} ")" option

    case $option in
        1)
            echo -e "\n${GREEN}══════════════════════════════════════════════════${NC}"
            echo -e "${GREEN}           🚀 INSTALLATION STARTING                ${NC}"
            echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
            echo -e "${CYAN}Initializing installation...${NC}"
            echo -e "${YELLOW}This will set up the complete dashboard environment.${NC}"
            echo -e "${CYAN}Please wait while we download and configure...${NC}\n"
            
            echo -e "${BLUE}[1/4]${NC} ${CYAN}Downloading installer...${NC}"
            bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/panel/Dashboard-v3.sh)
            
            echo -e "\n${GREEN}✅ Installation process initiated!${NC}"
            echo -e "${CYAN}Follow the on-screen instructions to complete setup.${NC}"
            ;;
            
        2)
            echo -e "\n${YELLOW}══════════════════════════════════════════════════${NC}"
            echo -e "${YELLOW}           🔄 UPDATE IN PROGRESS                   ${NC}"
            echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
            
            if [ ! -d "/var/www/mythicaldash" ]; then
                echo -e "${RED}❌ Error: MythicalDash directory not found!${NC}"
                read -p "Press Enter to continue..."
                continue
            fi
            
            cd /var/www/mythicaldash
            echo -e "${BLUE}[1/6]${NC} ${CYAN}Downloading latest version...${NC}"
            curl -Lo MythicalDash.zip https://github.com/MythicalLTD/MythicalDash/releases/download/3.2.3/MythicalDash.zip
            unzip -o MythicalDash.zip -d /var/www/mythicaldash
            dos2unix arch.bash
            sudo bash arch.bash
            composer install --no-dev --optimize-autoloader
            ./MythicalDash -migrate
            chown -R www-data:www-data /var/www/mythicaldash/*
            
            echo -e "\n${GREEN}✅ Update completed by SDGAMER!${NC}"
            ;;
            
        3)
            echo -e "\n${RED}══════════════════════════════════════════════════${NC}"
            echo -e "${RED}           ⚠️  UNINSTALL WARNING!                  ${NC}"
            echo -e "${RED}══════════════════════════════════════════════════${NC}"
            read -p "$(echo -e "${RED}Are you absolutely sure? (y/N):${NC} ")" confirm
            
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
                echo -e "\n${RED}🗑️  Starting uninstall process...${NC}"
                mariadb -u root -p -e "DROP DATABASE IF EXISTS mythicaldash; DROP USER IF EXISTS 'mythicaldash'@'127.0.0.1'; FLUSH PRIVILEGES;"
                rm -rf /var/www/mythicaldash
                sudo crontab -l | grep -v 'php /var/www/mythicaldash/crons/server.php' | sudo crontab - || true
                rm /etc/nginx/sites-available/MythicalDash.conf /etc/nginx/sites-enabled/MythicalDash.conf 2>/dev/null
                systemctl restart nginx
                echo -e "\n${GREEN}✅ Uninstall complete by SDGAMER!${NC}"
            else
                echo -e "${YELLOW}❌ Uninstall cancelled.${NC}"
            fi
            ;;
            
        4)
            echo -e "\n${MAGENTA}🔄 REDIRECTING TO Shubham PANEL...${NC}"
            bash <(curl -sL https://raw.githubusercontent.com/ArainCloud07/Panel/refs/heads/main/run.sh)
            exit 0
            ;;
            
        *)
            echo -e "\n${RED}❌ INVALID SELECTION! Try 1-4.${NC}"
            ;;
    esac

    echo ""
    read -p "$(echo -e "${CYAN}Press ${BOLD}Enter${NC}${CYAN} to continue...${NC}")" dummy
done
