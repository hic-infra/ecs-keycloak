variable "name" {
  type        = string
  default     = "keycloak-staging"
  description = "Name used for ECS cluster resources"
}

variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region name"
}

variable "keycloak-image" {
  type        = string
  default     = "ghcr.io/hic-infra/ecs-keycloak:2.1.0"
  description = "Keycloak image including registry"
}

variable "lb-cidr-blocks-in" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks to allow access to the load balancer"
}

variable "vpc-id" {
  type        = string
  default     = ""
  description = "VPC ID, if empty creates a new VPC"
}

variable "public-subnets" {
  type        = list(string)
  default     = []
  description = "Public subnet IDs, must be defined if vpc-id is provided"
}

variable "private-subnets" {
  type        = list(string)
  default     = []
  description = "Private subnet IDs, must be defined if vpc-id is provided"
}

variable "db-name" {
  type        = string
  default     = "keycloak"
  description = "Keycloak DB name"
}

variable "db-username" {
  type        = string
  default     = "keycloak"
  description = "Keycloak DB username"
}

variable "db-snapshot-identifier" {
  type        = string
  default     = null
  description = "If creating a new DB restore from this snapshot"
}

variable "db-instance-type" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance type: https://aws.amazon.com/rds/instance-types/"
}

variable "loadbalancer-certificate-arn" {
  type        = string
  description = "ARN of the ACM certificate to use for the load balancer"
}

variable "keycloak-hostname" {
  type        = string
  default     = ""
  description = "Keycloak hostname, if empty uses the load-balancer hostname"
}

variable "keycloak-loglevel" {
  type        = string
  default     = "INFO"
  description = "Keycloak log-level e.g. DEBUG."
}

variable "desired-count" {
  type        = number
  description = "Number of Keycloak containers to run, set to 0 for DB maintenance"
  default     = 1
}

variable "default-tags" {
  type = map(any)
  default = {
    CreatedBy = "infra@example.org"
    Proj      = "infra-keycloak"
  }
  description = "Default AWS tags to apply to all resources"
}
