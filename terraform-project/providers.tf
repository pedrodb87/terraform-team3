terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.30.0"
    }
  }
}

provider "google" {
  project = "plucky-tract-350819"
  region  = var.region
  zone = var.zone

}