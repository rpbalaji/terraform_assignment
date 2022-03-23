terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.6.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

terraform {
  backend "s3" {
    bucket     = "statefile-balaji"
    region     = "us-east-1"
    key        = "tf-state"
    encrypt    = true
    access_key = ""
    secret_key = ""
  }
}
