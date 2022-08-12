## in your CLI git clone git@github.com:pedrodb87/terraform-team3.git

## 11 min  VIDEO EXPLANATION available at: https://youtu.be/Jb3lalGZWSQ

## in GCP you wont be able to access/create your resources without a project already set. Go to the project folder and do terraform init and terraform apply. If you get an error, make sure you have cloud API enabled. If you don’t have it available terraform will give you a link with the information to enable it. Once enabled, wait a few minutes while it propagates to the GC systems. 

# Once a project is created, take note of the project name and ID. 
		
# Look for variables file and edit the name of the project into the default part. In our case the ID of our project is : 
		
# plucky-tract-350819
		
#  So in variables for the example case we put this project ID in the default section like so: 
		
		
		variable "project_name" {
		  type        = string
		  default     = "plucky-tract-350819"
		  description = "enter your project name"
		}
		
		
# this part tells google to look for a billing account named "My Billing Account". So "My Billing Account" billing account must be created first in the console for this script to run. If there is a different billing account you would like to use for this project, you can specify it and just change the name in the block of code.
		
		data "google_billing_account" "acct" {
		    display_name = "My Billing Account"
		    open = true
		}
		
# this part creates a random ID and assigns it to our project.
		
		
		resource "random_password" "password" {
		    length = 16
		    numeric = false
		    special = false
		    lower = true
		    upper = false
		}
		resource "google_project" "testproject" {
		    name = "Team3-project"
		    project_id = random_password.password.result
		    billing_account = data.google_billing_account.acct.id
		}
		
		
# this part enables the services so we can provision the resources
		
		
		  provisioner "local-exec" {
		    command = <<-EOT
		        gcloud services enable compute.googleapis.com
		        gcloud services enable dns.googleapis.com
		        gcloud services enable storage-api.googleapis.com
		        gcloud services enable container.googleapis.com
		    EOT
		  }
		}
		
		
# Once created make sure you see your project ID in yellow color to make sure you are inside your project and can start provisioning resources. you can also run the following command to set the environment to the right project.

gcloud config set project [PROJECT_ID]

## exit the project folder and make sure you are in the "terraform-project" folder and do terraform init. make sure the project Id is set in the variables file to the correct project ID you just created and do terraform apply -auto-approve and it will build all resources needed for a fully functioning three tier application.

## the end result should be an autoscaler with a minimum of 1 instance with a load balancer hosting a webserver connected to a database in the backend inside a global VPC. the webserver instance will have wordpress installed and one would just need to edit the website in the backend to ones preference.
		
#	2) Build a vpc with automatic creation of subnets:
#		a. Created a global VPC where our resources are going to be deployed. Make use of the block of code found in the terraform registry by searching for VPC.

  resource "google_compute_network" "vpc-network-team3" {
     name                    = var.vpc_name
     auto_create_subnetworks = "true"
     routing_mode            = "GLOBAL"
}


## Create an autoscaler with minimum 1 instance running
##	a. Takes from a target pool
##		b. Managed by an instance group manager
##		c. Create an instance image


# this block of code adds an autoscaling group in a zone specified in the variables file using an instance group manager as a target. this autoscaler is dependent on a SQL database. which means it will be created after the database is created. this is done to ensure that we automatically get the right credentials into our instance template metadata script.


  resource "google_compute_autoscaler" "team3" {
       depends_on = [
          google_sql_database_instance.database,
          local_file.postfix_config
    ]
  name   = var.ASG_name
  zone   = var.zone
  target = google_compute_instance_group_manager.my-igm.self_link



# section where you can define the number of instances running by editing the variables file under maximum or minimum
  
autoscaling_policy {
    max_replicas    = var.maximum_instances
    min_replicas    = var.minimum_instances
    cooldown_period = 60
  }
}


# creating a machine template so the autoscaling knows what type of machine to work with. this section is dependent on the database instance. This is to ensure that we have the right credentials for the script that is going to be used for boot straping our machine. we must add the tags needed for the firewall to be attached to this instance so it can be reached via the desired ports. (in our case 80 443 22 3406)


resource "google_compute_instance_template" "compute-engine" {
     depends_on = [
        google_sql_database_instance.database,
        local_file.postfix_config
    ]
  name                    = var.template_name
  machine_type            = var.machine_type
  can_ip_forward          = false
  project                 = var.project_name
  resource "google_compute_instance_template" "compute-engine" {
     depends_on = [
        google_sql_database_instance.database,
      
    ]
  name                    = var.template_name
  machine_type            = var.machine_type
  can_ip_forward          = false
  project                 = var.project_name
  metadata_startup_script = <<SCRIPT
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
    sed 's/'database_name_here'/'${google_sql_database.database.name}'/g' /var/www/html/wp-config.php -i
    sed 's/'username_here'/'${google_sql_user.users.name}'/g' /var/www/html/wp-config.php -i
    sed 's/'password_here'/'${var.db_password}'/g' /var/www/html/wp-config.php -i
    sed 's/'localhost'/'${google_sql_database_instance.database.ip_address.0.ip_address}'/g' /var/www/html/wp-config.php -i
    sed 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/sysconfig/selinux -i
    getenforce
    setenforce 0
    chown -R apache:apache /var/www/html/
    systemctl start httpd
    systemctl enable httpd
    SCRIPT

  tags = ["wordpress-firewall"]

  disk {
    source_image = data.google_compute_image.centos_7.self_link
  }

  network_interface {
    network = google_compute_network.vpc-network-team3.id
    access_config {
      // Include this section to give the VM an external ip address
    }

  }
}
  
  tags = ["wordpress-firewall"]
  disk {
    source_image = data.google_compute_image.centos_7.self_link
  }
  network_interface {
    subnetwork = google_compute_network.vpc-network-team3.id
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
}



# creating a target pool
  resource "google_compute_target_pool" "team3" {
    name    = var.targetpool_name
    project = var.project_name
    region  = var.region
}



# creating a group manager for the instances.
  resource "google_compute_instance_group_manager" "my-igm" {
    name    = var.igm_name
    zone    = var.zone
    project = var.project_name
    version {
      instance_template = google_compute_instance_template.compute-engine.self_link
      name              = "primary"
  }
    target_pools       = [google_compute_target_pool.team3.self_link]
    base_instance_name = "team3"
}


# indicating the image for the instance.
 
 data "google_compute_image" "centos_7" {
    family  = "centos-7"
    project = "centos-cloud"
}

##	Creation of a load balancer targeting the pool
## We used a module to create our load balancer and aim it to the pool  created by the autoscaler and selecting it to operate in our VPC.


# module for the load balancer.

module "lb" {
  source       = "GoogleCloudPlatform/lb/google"
  version      = "2.2.0"
  region       = var.region
  name         = var.lb_name
  service_port = 80
  target_tags  = ["my-target-pool"]
  network      = google_compute_network.vpc-network-team3.name
}

# Create a database instance into which our database is gonna be created. The code is dynamic and will allow us to change the name, version, region, password and project.  Make sure this database can accept traffic from specified networks by modifying the settings, ipv4 enabled and specifying the authorized networks. This is the user and the allowed ip range for this user. 

# this code of block will provision a database instance. specify the version, the region and the password in the variables file 

resource "google_sql_database_instance" "database" {
  name                = var.dbinstance_name
  database_version    = var.data_base_version
  region              = var.region
  root_password       = var.db_password
  deletion_protection = "false"
  project             = var.project_name


  settings {
    tier = "db-f1-micro"
ip_configuration {
      ipv4_enabled = "true"
      authorized_networks {
        value           = var.authorized_networks
        name            = var.db_username
        
      }
    
    # location_preference {
    #   zone = var.zone
    # }
    }
}
}

# Create a database inside of the database instance 
	
	
	resource "google_sql_database" "database" {
	  name     = var.db_name
	  instance = google_sql_database_instance.database.name
	}
	
# Create an user 
	
	resource "google_sql_user" "users" {
	  name     = var.db_username
	  instance = google_sql_database_instance.database.name
	  host     = var.db_host
	  password = var.db_password
	}
	
