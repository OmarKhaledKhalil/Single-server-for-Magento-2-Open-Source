#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo dnf update -y
sudo dnf install -y epel-release

# Install required dependencies
echo "Installing PHP, Nginx, MySQL, Redis, OpenSearch, and Varnish..."
sudo dnf install -y php php-cli php-fpm php-mysqlnd php-xml php-mbstring php-curl \
    php-intl php-bcmath php-soap php-zip php-gd php-opcache unzip git curl composer \
    nginx mysql-server redis varnish java-11-openjdk opensearch

# Start and enable services
echo "Starting services..."
sudo systemctl enable --now php-fpm nginx mysqld redis varnish opensearch

# Secure MySQL and create Magento database
echo "Configuring MySQL..."
mysql -u root <<EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
CREATE DATABASE magento;
CREATE USER 'magento'@'%' IDENTIFIED BY 'yourpassword';
GRANT ALL PRIVILEGES ON magento.* TO 'magento'@'%';
FLUSH PRIVILEGES;
EOF

# Allow MySQL external access
sudo sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' /etc/my.cnf.d/mysql-server.cnf
sudo systemctl restart mysqld

# Configure Redis for Magento
echo "Configuring Redis..."
sudo sed -i 's/^bind 127.0.0.1.*/bind 0.0.0.0/' /etc/redis.conf
echo "maxmemory-policy allkeys-lru" | sudo tee -a /etc/redis.conf
sudo systemctl restart redis

# Configure OpenSearch
echo "Configuring OpenSearch..."
sudo sed -i 's/^network.host: localhost/network.host: 0.0.0.0/' /etc/opensearch/opensearch.yml
echo "bootstrap.memory_lock: true" | sudo tee -a /etc/opensearch/opensearch.yml
sudo systemctl restart opensearch

# Install and configure Magento
echo "Installing Magento..."
cd /var/www/
sudo git clone https://github.com/magento/magento2.git magento
cd magento
sudo composer install --no-dev

# Set correct permissions
echo "Setting file permissions..."
sudo chown -R nginx:nginx /var/www/magento
sudo chmod -R 775 /var/www/magento

# Install Magento
sudo -u nginx bin/magento setup:install --base-url=http://magento.local --db-host=127.0.0.1 \
    --db-name=magento --db-user=magento --db-password=yourpassword \
    --cache-backend=redis --search-engine=opensearch --opensearch-host=127.0.0.1

# Configure Nginx for Magento
echo "Configuring Nginx..."
sudo tee /etc/nginx/conf.d/magento.conf <<EOF
server {
    listen 80;
    server_name magento.local;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
sudo systemctl restart nginx

# Configure Varnish
echo "Configuring Varnish..."
sudo sed -i 's/.port = "80";/.port = "8080";/' /etc/varnish/default.vcl
sudo systemctl restart varnish

# Enable HTTPS with self-signed SSL
echo "Setting up SSL..."
sudo dnf install -y mod_ssl
sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=magento.local" \
    -keyout /etc/ssl/private/magento.key -out /etc/ssl/certs/magento.crt
sudo tee /etc/nginx/conf.d/magento_ssl.conf <<EOF
server {
    listen 443 ssl;
    server_name magento.local;

    ssl_certificate /etc/ssl/certs/magento.crt;
    ssl_certificate_key /etc/ssl/private/magento.key;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
sudo systemctl restart nginx

echo "Magento setup completed!"
