terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket  = "kmps-iot-terraform"
    key     = "terraform.c8.ec2.tfstate"
    region  = "eu-west-1"
    profile = "tfuser"
  }
}

provider "aws" {
  profile = "tfuser"
  region  = "eu-west-1"
}
