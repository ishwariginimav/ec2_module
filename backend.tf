provider "aws" {
  region = var.region_name  # Update with your desired region
}

terraform {
  backend "s3" {
    bucket         = "my-s3-bucket-ish"
    key            = "ec2_module.tfstate"
    region         = "us-east-1"  # Update with your desired region
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
