variable "name" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "allocated_storage" {
  type = number
}
variable "max_allocated_storage" {
  type = number
}
variable "database_name" {
  type = string
}
variable "master_username" {
  type = string
}
variable "tags" {
  type = map(string)
}
