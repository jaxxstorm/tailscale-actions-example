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
    mysql = {
      source = "petoju/mysql"
      version = "3.0.62"
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

provider "mysql" { 
  alias = "dev"
  endpoint = "${module.db-dev.db_instance_endpoint}"
  username = "${module.db-dev.db_instance_username}"
  password = "${module.db-dev.db_instance_password}"
}

provider "mysql" { 
  alias = "prod"
  endpoint = "${module.db-prod.db_instance_endpoint}"
  username = "${module.db-prod.db_instance_username}"
  password = "${module.db-prod.db_instance_password}"
  
}