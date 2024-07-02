terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0"
    }
  }
}


provider "aws" {
  alias  = "dev"
  assume_role {
    role_arn = "arn:aws:iam::565485516070:role/OrganizationAccountAccessRole"
  }
  region = "us-west-2"
}


provider "aws" {
  alias  = "shared"
  assume_role {
    role_arn = "arn:aws:iam::471112515498:role/OrganizationAccountAccessRole"
  }
  region = "us-west-2"
}


provider "aws" {
  alias  = "prod"
  assume_role {
    role_arn = "arn:aws:iam::780219548054:role/OrganizationAccountAccessRole"
  }
  region = "us-west-2"
}