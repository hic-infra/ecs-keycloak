terraform {
  required_providers {
    # ~> MAJOR.MINOR allows the MINOR version to be updated in .terraform.lock.hcl
    # by running `terraform init -backend=false -upgrade`
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.25"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 2.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.3"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }
  }

  required_version = ">= 1.2.5"
}

