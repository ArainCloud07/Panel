#!/usr/bin/env bash
# ==========================================
#   🚀 Auto Installer
# ==========================================

set -u

# --- ANSI COLORS ---
C=$'\033[36m'  # Cyan
G=$'\033[32m'  # Green
R=$'\033[31m'  # Red
B=$'\033[34m'  # Blue
Y=$'\033[33m'  # Yellow
W=$'\033[97m'  # White
N=$'\033[0m'   # Reset

# --- HEADER FUNCTION ---
header() {
    clear
    echo -e "${B}  __  __       _         __  __                  ${N}"
    echo -e "${B} |  \/  | __ _(_)_ __   |  \/  | ___ _ __  _   _ ${N}"
    echo -e "${B} | |\/| |/ _\` | | '_ \  | |\/| |/ _ \ '_ \| | | |${N}"
    echo -e "${B} | |  | | (_| | | | | | | |  | |  __/ | | | |_| |${N}"
    echo -e "${B} |_|  |_|\__,_|_|_| |_| |_|  |_|\___|_| |_|\__,_|${N}"
    echo -e "${B}=====================================================${N}"
    echo -e "${Y}      🚀 Power By Shubham      ${N}"
    echo -e "${B}=====================================================${N}"
    echo ""
}

# --- PAUSE FUNCTION ---
pause() {
    echo ""
    read -p "${W}Press [Enter] to return to menu...${N}" dummy
}

# --- MAIN LOOP ---
while true; do
    header
    echo -e "${C} 1) ${W}Panel Installer ${G}(any vps)${N}"
    echo -e "${C} 2) ${W}Node Installer ${G}(any vps)${N}"
    echo -e "${R} 3) Exit${N}"
    echo ""
    echo -e "${B}=====================================================${N}"
    read -p "${Y}👉 Select an option [1-10]: ${N}" choice

    case $choice in
        1)
            echo ""
            echo -e "${Y}🔄 Installing Panel.${N}"
            bash <(curl -fsSL https://raw.githubusercontent.com/ArainCloud07/Panel/refs/heads/main/Oversee/Oversee.sh)
            pause
            ;;
        2)
            echo ""
            echo -e "${Y}🛠️  Installing Node.${N}"
            bash <(curl -fsSL https://raw.githubusercontent.com/ArainCloud07/Panel/refs/heads/main/Oversee/node)
            pause
            ;;

        3)
            echo ""
            echo -e "${G}👋 Exiting... Thanks for using!${N}"
            exit 0
            ;;
        *)
            echo ""
            echo -e "${R}❌ Invalid Option! Please select between 1-10.${N}"
            sleep 2
            ;;
    esac
done
EOF
