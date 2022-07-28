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
  default     = "99"
  description = "maximum desired instances running at a given point"
}



