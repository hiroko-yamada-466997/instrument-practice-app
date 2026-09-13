terraform {
  required_version = "= 1.16.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.62.0"

    }


  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = local.tags

  }
}
