variable "machine_type" {
  type        = string
  default     = "e2-medium"
  description = "add your machine type"
}

variable "project_name" {
  type        = string
  default     = "plucky-tract-350819"
  description = "enter your project name"
}


variable "region" {
  type        = string
  default     = "us-east1"
  description = "add desired region"
}


variable "zone" {
  type        = string
  default     = "us-east1-b"
  description = "zone where to deploy resource"
}

variable "minimum_instances" {
  type        = number
  default     = "1"
  description = "minimum desired instances running at a given point"
}

variable "maximum_instances" {
  type        = number
  default     = "5"
  description = "maximum desired instances running at a given point"
}

variable "data_base_version" {
  type        = string
  default     = "MYSQL_5_6" #MYSQL_5_6, MYSQL_5_7, MYSQL_8_0, POSTGRES_9_6,POSTGRES_10, POSTGRES_11, POSTGRES_12, POSTGRES_13, SQLSERVER_2017_STANDARD, SQLSERVER_2017_ENTERPRISE, SQLSERVER_2017_EXPRESS, SQLSERVER_2017_WEB
  description = "specifies the database version"
}


variable "db_password" {
  type        = string
  default     = "admin"
  description = "description"
}


