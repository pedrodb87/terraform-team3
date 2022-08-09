#!/bin/bash
yum install httpd wget unzip epel-release mysql -y
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php56   [Install PHP 5.6]
yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
wget https://wordpress.org/latest.tar.gz
tar -xf latest.tar.gz -C /var/www/html/
mv /var/www/html/wordpress/* /var/www/html/
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
chmod 666 /var/www/html/wp-config.php
sed 's/'database_name_here'/'random'/g' /var/www/html/wp-config.php -i
sed 's/'username_here'/'pedrobalza'/g' /var/www/html/wp-config.php -i
sed 's/'password_here'/'admin'/g' /var/www/html/wp-config.php -i
sed 's/'localhost'/'34.125.195.242'/g' /var/www/html/wp-config.php -i
sed 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/sysconfig/selinux -i
getenforce
setenforce 0
chown -R apache:apache /var/www/html/
systemctl start httpd
systemctl enable httpd 
