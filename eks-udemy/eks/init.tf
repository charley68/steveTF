terraform {

  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.0"
    }
  }

}

provider "aws" {
  region = var.region
}