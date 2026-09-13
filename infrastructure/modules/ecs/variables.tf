variable "name" {
  type = string
}
variable "region" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "frontend_security_group_id" {
  type = string
}
variable "backend_security_group_id" {
  type = string
}
variable "frontend_target_group_arn" {
  type = string
}
variable "backend_target_group_arn" {
  type = string
}
variable "execution_role_arn" {
  type = string
}
variable "task_role_arn" {
  type = string
}
variable "frontend_image" {
  type = string
}
variable "backend_image" {
  type = string
}
variable "frontend_log_group" {
  type = string
}
variable "backend_log_group" {
  type = string
}
variable "database_name" {
  type = string
}
variable "database_host" {
  type = string
}
variable "database_port" {
  type = number
}
variable "database_secret_arn" {
  type = string
}
variable "django_secret_parameter_arn" {
  type = string
}
variable "application_hostname" {
  type = string
}
variable "cpu" {
  type    = number
  default = 256
}
variable "memory" {
  type    = number
  default = 512
}
variable "cpu_architecture" {
  type    = string
  default = "X86_64"
}
variable "desired_count" {
  type    = number
  default = 0
}
variable "tags" {
  type = map(string)
}
