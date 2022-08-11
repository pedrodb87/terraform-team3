

# resource "local_file" "postfix_config" {
#     depends_on = [
#         google_sql_database_instance.database
#     ]
#       filename = var.postfix_config_path
#   content  = local.postfix_config
# }
# # variable "hostname" {
# #      default = "example.com"
# # }
# # variable "domain_name" {
# #   default = "example.com"
# # }
# variable "postfix_config_path" {
#     default = "/home/Terraform-Project-team3/terraform-team3-project/terraform-project/wordpress.sh"
  
# }


# locals {
#   postfix_config = <<-EOT
# #!/bin/bash
# yum install httpd wget unzip epel-release mysql -y
# yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
# yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# yum -y install yum-utils
# yum-config-manager --enable remi-php56   [Install PHP 5.6]
# yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
# wget https://wordpress.org/latest.tar.gz
# tar -xf latest.tar.gz -C /var/www/html/
# mv /var/www/html/wordpress/* /var/www/html/
# cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
# chmod 666 /var/www/html/wp-config.php
# sed 's/'database_name_here'/'${google_sql_database.database.name}'/g' /var/www/html/wp-config.php -i
# sed 's/'username_here'/'${google_sql_user.users.name}'/g' /var/www/html/wp-config.php -i
# sed 's/'password_here'/'${var.db_password}'/g' /var/www/html/wp-config.php -i
# sed 's/'localhost'/'${google_sql_database_instance.database.ip_address.0.ip_address}'/g' /var/www/html/wp-config.php -i
# sed 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/sysconfig/selinux -i
# getenforce
# setenforce 0
# chown -R apache:apache /var/www/html/
# systemctl start httpd
# systemctl enable httpd 
# EOT
# }