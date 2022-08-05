#this block of code adds a VPC
resource "google_compute_subnetwork" "network-ip-ranges" {
  name          = "public"
  ip_cidr_range = "192.168.10.0/24"
  # ip_cidr_range = "10.2.0.0/16"
  region  = var.region
  network = google_compute_network.vpc-network-team3.id
  # secondary_ip_range {
  #   range_name    = "secondary-range"
  #   ip_cidr_range = "192.168.10.0/24"
  # }
}


resource "google_compute_network" "vpc-network-team3" {
  name                    = "vpc-network-team"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}