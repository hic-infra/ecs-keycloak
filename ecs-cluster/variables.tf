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
  default     = "ghcr.io/hic-infra/ecs-keycloak:1.0.0-beta.1"
  description = "Keycloak image including registry"
}

variable "lb-cidr-blocks-in" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks to allow access to the load balancer"
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

variable "loadbalancer-certificate-arn" {
  type        = string
  description = "ARN of the ACM certificate to use for the load balancer"
}

variable "keycloak-hostname" {
  type        = string
  default     = ""
  description = "Keycloak hostname, if empty uses the load-balancer hostname"
}

variable "default-tags" {
  type = map(any)
  default = {
    CreatedBy = "infra@example.org"
    Proj      = "infra-keycloak"
  }
  description = "Default AWS tags to apply to all resources"
}
