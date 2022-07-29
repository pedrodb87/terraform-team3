#this block of code adds a VPC

resource "google_compute_network" "vpc-network-team3" {
  name                    = "vpc-network-team"
  auto_create_subnetworks = "true"
}

#this block of codeadds an autoscaling group in a zone specified in the variables file using an instance group manager as a target

resource "google_compute_autoscaler" "team3" {
  name   = "my-autoscaler-team3"
  zone   = var.zone
  target = google_compute_instance_group_manager.my-igm.self_link

  #section where you can define the number of instances running by editing the variables file under maximum or minimum

  autoscaling_policy {
    max_replicas    = var.maximum_instances
    min_replicas    = var.minimum_instances
    cooldown_period = 60

  }
}

#creating a machine template so the autoscaling knows what type of machine to work with.

resource "google_compute_instance_template" "compute-engine" {
  name           = "my-instance-template"
  machine_type   = var.machine_type
  can_ip_forward = false
  project        = var.project_name


  disk {
    source_image = data.google_compute_image.centos_7.self_link
  }

  network_interface {
    network = google_compute_network.vpc-network-team3.name
  }
}

#creating a target pool

resource "google_compute_target_pool" "team3" {
  name    = "my-target-pool"
  project = var.project_name
  region  = var.region
}

#creating a group manager for the instances.
resource "google_compute_instance_group_manager" "my-igm" {
  name    = "my-igm"
  zone    = var.zone
  project = var.project_name
  version {
    instance_template = google_compute_instance_template.compute-engine.self_link
    name              = "primary"
  }
  target_pools       = [google_compute_target_pool.team3.self_link]
  base_instance_name = "team3"
}

#indicating the image for the instance.

data "google_compute_image" "centos_7" {
  family  = "centos-7"
  project = "centos-cloud"
}

#module for the load balancer.

module "lb" {
  source       = "GoogleCloudPlatform/lb/google"
  version      = "2.2.0"
  region       = var.region
  name         = "load-balancer"
  service_port = 80
  target_tags  = ["my-target-pool"]
  network      = google_compute_network.vpc-network-team3.name
}


#this code of block will provision a database. specify the version, the region and the password in the variables file 

resource "google_sql_database_instance" "database" {
  name                = "main-database-team3"
  database_version    = var.data_base_version
  region              = var.region
  root_password       = var.db_password
  deletion_protection = "false"
  project             = var.project_name

  settings {
    tier = "db-f1-micro"
  }
}





# resource "google_compute_instance" "pedrito-test" {
#   name         = "pedrito"
#   machine_type = "e2-small"
#   zone         = "us-east1-b"

#   tags = ["team", "three"]

#   boot_disk {
#     initialize_params {
#       image = "centos-7-v20220719"
#     }
#   }

#   // Local SSD disk
#   # scratch_disk {
#   #   interface = "SCSI"
#   # }

#   network_interface {
#     network = google_compute_network.vpc-network-team3.name

#     access_config {
#       // Ephemeral public IP
#     }
#   }
# }