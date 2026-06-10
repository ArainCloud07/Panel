#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# ASCII Art Function
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ____  _   _ _   _ ____  _   _    _    __  __ "
    echo " / ___|| | | | | | | __ )| | | |  / \  |  \/  |"
    echo " \___ \| |_| | | | |  _ \| |_| | / _ \ | |\/| |"
    echo "  ___) |  _  | |_| | |_) |  _  |/ ___ \| |  | |"
    echo " |____/|_| |_|\___/|____/|_| |_/_/   \_\_|  |_|"
    echo -e "${NC}"
    echo -e "${BLUE}    Hydra Panel + Daemon Installer (Shubham)    ${NC}"
    echo "----------------------------------------------------"
}
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root.${NC}"
  exit 1
fi

echo -e "${CYAN}$ascii_art${NC}"

echo "* Installing Dependencies"

# Update package list and install dependencies
# Using dnf for Fedora instead of apt
sudo dnf check-update
sudo dnf install -y curl git

# NodeSource setup for Fedora/RHEL/CentOS (RPM based)
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -

# Install Node.js
sudo dnf install -y nodejs

echo_message "* Installed Dependencies"

echo_message "* Installing Files"

# Create directory, clone repository, and install files
# (This section remains OS-agnostic)
git clone https://github.com/draco-labes/oversee-fixed.git && cd oversee-fixed && npm install && npm run seed && npm run createUser && node . 

echo_message "* Installed Files"

echo_message "* Starting Hydra"

echo "* Hydra Installed and Started on Port 3001"
