terraform {
  required_providers {
    # ~> MAJOR.MINOR allows the MINOR version to be updated in .terraform.lock.hcl
    # by running `terraform init -backend=false -upgrade`
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.26"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }

  required_version = ">= 1.5.0"
}
