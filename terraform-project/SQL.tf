#this code of block will provision a database. specify the version, the region and the password in the variables file 

resource "google_sql_database_instance" "database" {
  name                = "unit2s"
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
        value           = "0.0.0.0/0"
        name            = "pedrobalza"
        
      }
    
    # location_preference {
    #   zone = var.zone
    # }
    }
}
}

resource "google_sql_database" "database" {
  name     = "wordpress"
  instance = google_sql_database_instance.database.name
}

resource "google_sql_user" "users" {
  name     = "pedrobalza"
  instance = google_sql_database_instance.database.name
  host     = "%" 
  password = "admin"
}

