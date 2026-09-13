variable "name" {
  type = string
}
variable "region" {
  type = string
}
variable "github_repository" {
  type = string
}
variable "github_subject" {
  type    = string
  default = "ref:refs/heads/main"
}
variable "create_oidc_provider" {
  type = bool
}
variable "existing_oidc_provider_arn" {
  type     = string
  default  = null
  nullable = true
}
variable "django_secret_parameter_arn" {
  type = string
}
variable "ecr_repository_arns" {
  type = list(string)
}
variable "tags" {
  type = map(string)
}
