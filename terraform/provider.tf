terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
  /* setting backend */
  backend "s3" {
    bucket = "terraform-state-lock"
    key    = "metadata-service.tfstate"
    region = "us-east-1"
  }

  required_version = ">=1.4.4"
}

# setup aws provider for different regions
provider "aws" {
  region = "us-east-1"
  alias  = "primary_region"
}

provider "aws" {
  region = "ap-southeast-1"
  alias  = "secondary_region"
}