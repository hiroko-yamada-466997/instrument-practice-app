variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}
variable "aws_profile" {
  type     = string
  default  = null
  nullable = true
}
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
variable "public_subnets" {
  type = map(string)
  default = { "ap-northeast-1a" = "10.20.0.0/24", "ap-northeast-1c" = "10.20.1.0/24"
  }
}
variable "app_subnets" {
  type = map(string)
  default = { "ap-northeast-1a" = "10.20.10.0/24", "ap-northeast-1c" = "10.20.11.0/24"
  }
}
variable "db_subnets" {
  type = map(string)
  default = { "ap-northeast-1a" = "10.20.20.0/24", "ap-northeast-1c" = "10.20.21.0/24"
  }
}
variable "domain_name" {
  type     = string
  default  = null
  nullable = true
}
variable "route53_zone_id" {
  type     = string
  default  = null
  nullable = true
}
variable "budget_email" {
  type     = string
  default  = null
  nullable = true
}
variable "alert_email" {
  type     = string
  default  = null
  nullable = true
}
variable "django_secret_key" {
  type      = string
  sensitive = true
}
variable "github_repository" {
  type    = string
  default = "hiroko-yamada-466997/instrument-practice-app"
}
variable "github_subject" {
  type    = string
  default = "ref:refs/heads/main"
}
variable "create_github_oidc_provider" {
  type    = bool
  default = true
}
variable "existing_github_oidc_provider_arn" {
  type     = string
  default  = null
  nullable = true
  validation {
    condition     = var.create_github_oidc_provider || var.existing_github_oidc_provider_arn != null
    error_message = "Set an existing provider ARN when create_github_oidc_provider is false."


  }
}
