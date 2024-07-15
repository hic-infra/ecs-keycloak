terraform {
  required_providers {
    # ~> MAJOR.MINOR allows the MINOR version to be updated in .terraform.lock.hcl
    # by running `terraform init -backend=false -upgrade`
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  required_version = ">= 1.5.0"
}
