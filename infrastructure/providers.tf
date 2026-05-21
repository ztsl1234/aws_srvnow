terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "corporate-engineering-tf-state"
    key            = "data-platform/state.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      System      = "ServiceNow-Pipeline"
    }
  }
}