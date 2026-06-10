!/bin/bash

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

# Update package list and install dependencies
sudo apt update
sudo apt install -y curl software-properties-common
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install nodejs -y 
sudo apt install git -y

# Wings

git clone https://github.com/achul123/skyportd.git
cd skyportd 
npm install

echo_message "* cd skyportd"

echo_message "* paste your configure code"

echo_message "* pm2 start ."


