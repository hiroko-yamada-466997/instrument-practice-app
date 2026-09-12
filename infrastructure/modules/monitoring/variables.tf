variable "name" {
  type = string
}
variable "log_groups" {
  type    = list(string)
  default = []
}
variable "log_retention_days" {
  type    = number
  default = 14
}
variable "create_alert_topic" {
  type    = bool
  default = false
}
variable "alert_email" {
  type     = string
  default  = null
  nullable = true
}
variable "tags" {
  type = map(string)
}
