variable "machine_type" {
  type        = string
  default     = "e2-small"
  description = "add your machine type"
}

variable "project_name" {
  type        = string
  default     = "plucky-tract-350819"
  description = "enter your project name"
}


variable "region" {
  type        = string
  default     = "us-west4"
  description = "add desired region"
}


variable "zone" {
  type        = string
  default     = "us-west4-b"
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
  default     = "POSTGRES_14"
  description = "specifies the database version"
}


variable "db_password" {
  type        = string
  default     = ""
  description = "description"
}


