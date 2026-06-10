#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[1;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Redirect Function for Exit
exit_and_redirect() {
    echo -e "\n${MAGENTA}👋 Installation process finished.${NC}"
    echo -e "${CYAN}Press ${BOLD}Enter${NC}${CYAN} to return to Shubham Panel...${NC}"
    read -p "" 
    bash <(curl -sL https://raw.githubusercontent.com/ArainCloud07/Panel/refs/heads/main/run.sh)
    exit 0
}

# Function to get domain input with simple UI
get_domain() {
    echo -e "\n${GREEN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│              CTRLPANEL INSTALLATION SCRIPT             │${NC}"
    echo -e "${GREEN}│                    Powered by Shubham                  │${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e ""
    echo -e "${YELLOW}Please enter your domain name for CtrlPanel${NC}"
    echo -e "${BLUE}Example: panel.yourdomain.com${NC}"
    echo -e ""
    
    while true; do
        read -p "➤ Enter your domain: " DOMAIN_NAME
        
        if [ -z "$DOMAIN_NAME" ]; then
            print_error "Domain name cannot be empty. Please try again."
        elif ! echo "$DOMAIN_NAME" | grep -qE '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
            print_error "Invalid domain format. Please enter a valid domain."
        else
            break
        fi
    done
    
    echo -e ""
    echo -e "${GREEN}✓ Domain set to: $DOMAIN_NAME${NC}"
    echo -e "${YELLOW}Starting installation...${NC}"
    echo -e ""
}

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
        OS_VERSION=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release)
    else
        print_error "Unsupported operating system"
        exit_and_redirect
    fi
}

# Function to get web user and group
get_web_user() {
    if [ "$OS" = "debian" ] || [ "$OS" = "ubuntu" ]; then
        echo "www-data"
    else
        echo "nginx"
    fi
}

# Function to install dependencies for Debian/Ubuntu
install_debian() {
    echo -e "${YELLOW}📦 Detected Debian-based system ($OS $OS_VERSION)${NC}"
    apt update -y
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg lsb-release wget
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list
    apt update -y
    apt install -y php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip,intl,redis} mariadb-server nginx git redis-server
}

# Function to install dependencies for RHEL/CentOS
install_rhel() {
    echo -e "${YELLOW}📦 Detected RHEL-based system ($OS $OS_VERSION)${NC}"
    dnf install -y epel-release https://rpms.remirepo.net/enterprise/remi-release-${OS_VERSION%%.*}.rpm
    dnf module enable -y php:remi-8.3
    dnf install -y curl wget gnupg2
    dnf install -y php php-{common,cli,gd,mysqlnd,mbstring,bcmath,xml,fpm,curl,zip,intl,redis} mariadb-server nginx git redis
}

# Function to setup services
setup_services() {
    print_status "🔧 Setting up services..."
    systemctl enable --now redis-server 2>/dev/null || systemctl enable --now redis 2>/dev/null
    systemctl enable --now mariadb 2>/dev/null || systemctl enable --now mysql 2>/dev/null
    systemctl enable --now nginx
    systemctl enable --now php8.3-fpm 2>/dev/null || systemctl enable --now php-fpm 2>/dev/null
}

# Function to install Composer
install_composer() {
    print_status "📦 Installing Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
}

# Function to setup application
setup_application() {
    print_status "🚀 Setting up CtrlPanel application..."
    mkdir -p /var/www/ctrlpanel
    cd /var/www/ctrlpanel
    if [ -d ".git" ]; then
        git pull origin main
    else
        git clone https://github.com/Ctrlpanel-gg/panel.git ./
    fi
}

# Function to setup MariaDB database
setup_database() {
    print_status "🗄️ Setting up database..."
    DB_NAME=ctrlpanel
    DB_USER=ctrlpaneluser
    DB_PASS=$(openssl rand -base64 12)
    mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';"
    mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;"
    mariadb -e "FLUSH PRIVILEGES;"
    print_success "Database configured"
}

# Function to setup application dependencies and permissions
setup_app_dependencies() {
    print_status "📦 Installing PHP dependencies..."
    cd /var/www/ctrlpanel
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    php artisan storage:link
    WEB_USER=$(get_web_user)
    chown -R $WEB_USER:$WEB_USER /var/www/ctrlpanel/
    chmod -R 755 storage/ bootstrap/cache/
}

# Function to setup SSL certificates
setup_ssl() {
    print_status "🔒 Generating SSL..."
    mkdir -p /etc/certs/ctrlpanel
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/C=NA/ST=NA/L=NA/O=SDGAMER/CN=$DOMAIN_NAME" \
        -keyout /etc/certs/ctrlpanel/privkey.pem -out /etc/certs/ctrlpanel/fullchain.pem
}

# Function to create nginx configuration
create_nginx_config() {
    print_status "🌐 Creating Nginx config..."
    cat > /etc/nginx/sites-available/ctrlpanel.conf << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;
    return 301 https://\$server_name\$request_uri;
}
server {
    listen 443 ssl http2;
    server_name $DOMAIN_NAME;
    root /var/www/ctrlpanel/public;
    index index.php;
    ssl_certificate /etc/certs/ctrlpanel/fullchain.pem;
    ssl_certificate_key /etc/certs/ctrlpanel/privkey.pem;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF
    ln -sf /etc/nginx/sites-available/ctrlpanel.conf /etc/nginx/sites-enabled/ctrlpanel.conf
}

# Main script
main() {
    clear
    get_domain
    if [ "$EUID" -ne 0 ]; then print_error "Run as root"; exit_and_redirect; fi
    detect_os
    
    [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ] && install_debian || install_rhel
    
    setup_services
    install_composer
    setup_application
    setup_database
    setup_app_dependencies
    setup_ssl
    create_nginx_config
    
    print_status "Finalizing..."
    nginx -t && systemctl reload nginx
    
    # Final display
    echo -e "\n${GREEN}✅ INSTALLATION COMPLETE BY Shubham${NC}"
    echo -e "${YELLOW}URL:${NC} https://$DOMAIN_NAME"
    echo -e "${YELLOW}Path:${NC} /var/www/ctrlpanel"
    
    exit_and_redirect
}

main
