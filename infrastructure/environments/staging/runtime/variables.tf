variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}
variable "aws_profile" {
  type     = string
  default  = null
  nullable = true
}
variable "foundation_state_path" {
  type    = string
  default = "../foundation/terraform.tfstate"
}
variable "image_tag" {
  type        = string
  description = "Immutable Git commit SHA tag pushed to both ECR repositories"
}
variable "postgres_engine_version" {
  type        = string
  description = "RDS-supported PostgreSQL version confirmed before apply"
}
variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}
variable "database_name" {
  type    = string
  default = "instrument_practice"
}
variable "master_username" {
  type    = string
  default = "instrument_admin"
}
variable "cpu_architecture" {
  type    = string
  default = "X86_64"
  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "Use X86_64 or ARM64."

  }
}
variable "desired_count" {
  type        = number
  default     = 0
  description = "Keep at 0 for initial apply; set to 1 only after migration and fixture tasks succeed."
  validation {
    condition     = contains([0, 1], var.desired_count)
    error_message = "Staging desired_count must be 0 or 1."

  }
}
