terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }
  backend "s3" {
    bucket = "prometheuse-ec2-remote-state"
    key    = "prometheus-ec2-install"
    region = "us-east-1"
    dynamodb_table = "prometheuse-ec2-locking"
    }
  }
provider "aws" {
  # Configuration options
  region = "us-east-1"
}