resource "google_compute_network" "vpc-network-team3" {
  name                    = "vpc-network-team"
  auto_create_subnetworks = "true"
}

resource "google_compute_autoscaler" "team3" {
    name   = "my-autoscaler-team3"
  zone   = var.zone
  target = google_compute_instance_group_manager.my-igm.self_link
  

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

  }
}


resource "google_compute_instance_template" "compute-engine" {
name = "my-instance-template"
machine_type = var.machine_type
can_ip_forward = false
project = var.project_name


disk {
source_image = data.google_compute_image.centos_7.self_link
}

network_interface {
network = google_compute_network.vpc-network-team3.name
}
}

resource "google_compute_instance_group_manager" "my-igm" {
name = "my-igm"
zone = var.zone
project = var.project_name
version {
instance_template = google_compute_instance_template.compute-engine.self_link
name = "primary"
}
base_instance_name = "team3"
}

data "google_compute_image" "centos_7" {
family = "centos-7"
project = "centos-cloud"
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