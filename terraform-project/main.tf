resource "google_compute_network" "vpc_network-team3" {
  name                    = "vpc-network-team"
  auto_create_subnetworks = "true"
}






# resource "google_compute_instance" "pedrito-test" {
#   name         = "pedrito"
#   machine_type = "e2-small"
#   zone         = "us-east1-b"

#   tags = ["foo", "bar"]

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
#     network = "google_compute_network.vpc_network-team3.id"

#     access_config {
#       // Ephemeral public IP
#     }
#   }
# }