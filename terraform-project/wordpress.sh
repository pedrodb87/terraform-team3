#!/bin/bash 
# Install necessary tools
yum install httpd wget unzip epel-release mysql -y 
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm 
yum install yum-utils -y
# yum-config-manager --enable remi-php55
yum-config-manager --enable remi-php56   [Install PHP 5.6]
# yum-config-manager --enable remi-php72
yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo -y
# yum install php -y 
# yum install php-mysql -y 
# Download latest wordpress
wget https://wordpress.org/latest.tar.gz 
tar -xf latest.tar.gz -C /var/www/html/ 
mv /var/www/html/wordpress/* /var/www/html/ 
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
#increasing the memory limit to use with wordpress
sed -i -e "85adefine( 'WP_MEMORY_LIMIT', '256M' );" /var/www/html/wp-config.php
getenforce 
sed 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/sysconfig/selinux -i 
setenforce 0
chown -R apache:apache /var/www/html/
# Start web server
systemctl restart httpd
systemctl enable httpd
