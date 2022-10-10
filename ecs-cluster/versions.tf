terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.25.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "2.2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }

  required_version = ">= 1.2.5"
}

