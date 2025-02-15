# Single-server-for-Magento-2-Open-SourceMagento 2 Open Source Deployment with Vagrant and VirtualBox
**Project Overview**
This project automates the deployment of Magento 2 Open Source on a single server using Vagrant and VirtualBox. It includes a fully configured environment with essential services required to run Magento efficiently.

The provisioning script installs and configures:

Nginx (Web Server)
PHP-FPM (PHP Processor)
MySQL (Database Server)
Varnish (Full-Page Caching)
Redis (Session & Cache Storage)
OpenSearch (Search Engine)
SSL Configuration (Self-Signed for HTTPS)
This setup follows best practices for Magento performance, caching, and security.

Features
✅ Fully automated deployment using Vagrant
✅ Supports CentOS Stream 9 as the base OS
✅ Uses Nginx + Varnish as a performance-optimized stack
✅ Configured Redis for caching and OpenSearch for search indexing
✅ MySQL secured with a dedicated Magento database and user
✅ Self-signed SSL certificate for HTTPS support
✅ Modular structure for easy modifications & scalability

Prerequisites
Before setting up the project, ensure you have the following installed:

Vagrant
VirtualBox
Git

**Installation Instructions**
1. Clone the Repository
git clone https://github.com/OmarKhaledKhalil/Single-server-for-Magento-2-Open-Source.git
cd Single-server-for-Magento-2-Open-Source
2. Start the Virtual Machine
Run the following command to start the virtual environment:
vagrant up

This will:
Create a CentOS Stream 9 VM
Install and configure all required services
Deploy Magento 2 Open Source

3. Access the Server
Once provisioning is complete, you can SSH into the VM:
vagrant ssh SingleServer

5. Access Magento
Open your browser and visit:
http://magento.local
To access Magento Admin Panel:
http://magento.local/admin

**Configuration Details**
Service	IP Address	Port
Magento App	192.168.56.101	80 (HTTP) / 443 (HTTPS)
MySQL Database	192.168.56.101	3306
Redis Cache	192.168.56.101	6379
Varnish Cache	192.168.56.101	8080
OpenSearch	192.168.56.101	9200
Project Structure

.
├── setup_magento.sh        # Main provisioning script (installs Magento & dependencies)
├── Vagrantfile             # Vagrant configuration for VM setup
├── README.md               # Project documentation
├── .gitignore              # Ignore unnecessary files
Customization
Change Database Credentials
Modify setup_magento.sh:
mysql -u root -e "CREATE USER 'magento'@'%' IDENTIFIED BY 'yourpassword';"
Change Magento Base URL
Modify this line in setup_magento.sh:

bin/magento setup:install --base-url=http://magento.local
Troubleshooting
1. Virtual Machine Not Starting
If vagrant up fails, try:
vagrant destroy -f
vagrant up
2. Database Connection Issues
Verify MySQL is running:
sudo systemctl status mysqld
3. Permission Issues
Run:
sudo chown -R nginx:nginx /var/www/magento

This project is licensed under the MIT License.


Author
Omar Khaled Khalil
LinkedIn: - https://www.linkedin.com/in/omar-khaled-70a3191a2/
