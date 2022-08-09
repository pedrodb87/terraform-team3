## Make sure that a project is set. You wont be able to access/create your resources without a project already set. Go to the project folder and do terraform init and terraform apply. If you get an error, make sure you have cloud API enabled. If you don’t have it available terraform will give you a link with the information to enable it. Once enabled, wait a few minutes while it propagates to the GC systems. 

# Once a project is created, take note of the project name and ID. 
		
# Look for variables file and edit the name of the project into the default part. In our case the name of our project is : 
		
# plucky-tract-350819
		
#  So in our variables we will put this project name in the default section like so: 
		
		
		variable "project_name" {
		  type        = string
		  default     = "plucky-tract-350819"
		  description = "enter your project name"
		}
		
		
# this part tells google to look for a project named "My Billing Account"
		
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
		
		
# Once created make sure you see your project ID in yellow color to make sure you are inside your project and can start provisioning resources.
		
	2) Build a vpc with automatic creation of subnets:
		a. We created a global VPC where our resources are going to be deployed. We made use of the block of code found in the terraform registry by searching for VPC.


resource "google_compute_network" "vpc-network-team3" {
  name                    = var.vpc_name
  auto_create_subnetworks = "true"
  routing_mode            = "GLOBAL"
}


	1) Create an autoscaler with minimum 1 instance running
		a. Takes from a target pool
		b. Managed by an instance group manager
		c. Create an instance image


# this block of code adds an autoscaling group in a zone specified in the variables file using an instance group manager as a target
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


# creating a machine template so the autoscaling knows what type of machine to work with.
resource "google_compute_instance_template" "compute-engine" {
     depends_on = [
        google_sql_database_instance.database,
        local_file.postfix_config
    ]
  name                    = var.template_name
  machine_type            = var.machine_type
  can_ip_forward          = false
  project                 = var.project_name
  metadata_startup_script = file("${path.module}/wordpress.sh")
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

	1) Creation of a load balancer targeting the pool
We used a module to create our load balancer and aim it to the pool created by the autoscaler and selecting it to operate in our VPC.


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
	
