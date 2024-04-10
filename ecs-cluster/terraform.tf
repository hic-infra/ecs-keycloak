# The Terraform state should be stored in S3, but you must configure the S3 bucket/prefix separately.
# See example.s3.tfbackend
terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default-tags
  }
}
