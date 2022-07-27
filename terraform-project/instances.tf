resource "google_compute_instance" "pedrito-test" {
  name         = "pedrito"
  machine_type = "e2-small"
  zone         = "us-east1"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "CentOS 7"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}