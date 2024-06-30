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
  profile = "personal-development"
  region = "us-west-2"
}


provider "aws" {
  alias  = "shared"
  profile = "personal-shared"
  region = "us-west-2"
}


provider "aws" {
  alias  = "prod"
  profile = "personal-production"
  region = "us-west-2"
}