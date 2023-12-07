# PROVIDER
terraform {

  required_version = "~> 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.55"
    }
  }

  backend "s3" {
    bucket         = "baldedokinha"
    key            = "terraform.tfstate"
    dynamodb_table = "tabelacp3"
    region         = "us-east-1"
  }

}

provider "aws" {
  region                   = "us-east-1"
  # shared_config_files      = ["~/.aws/config"]
  # shared_credentials_files = ["~/.aws/credentials"]
  # profile                  = "fiap"
}




















