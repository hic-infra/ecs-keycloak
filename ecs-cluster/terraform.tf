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
