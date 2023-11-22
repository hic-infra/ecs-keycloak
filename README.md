# Keycloak on ECS with RDS

[![CI](https://github.com/hic-infra/ecs-keycloak/actions/workflows/ci.yml/badge.svg)](https://github.com/hic-infra/ecs-keycloak/actions/workflows/ci.yml)
[![Container build](https://github.com/manics/ecs-keycloak/actions/workflows/container.yml/badge.svg)](https://github.com/manics/ecs-keycloak/actions/workflows/container.yml)

This is a demo of running Keycloak on ECS with an RDS (PostgreSQL) database.

RDS (PostgreSQL) and Keycloak are run in a private subnet.

An application load-balancer in a public subnet routes traffic to the Keycloak application.

## Building the container image

Build an "optimised" Keycloak container using Docker or Podman ([`container/Dockerfile`](container/Dockerfile)), and push to ECR:

```
podman build --platform linux/amd64 -t ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/example/keycloak:YYYY-MM-DD container
aws ecr get-login-password --region REGION | podman login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com
podman push ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/example/keycloak:YYYY-MM-DD
```

## Deployment

Import a HTTPS certificate to ACM.
For testing you can create a self-signed certificate (run [`scripts/self-signed-cert.sh`](scripts/self-signed-cert.sh))

Create an S3 backend configuration file (see [`ecs-cluster/example.s3.tfbackend`](ecs-cluster/example.s3.tfbackend)).
Check the [Terraform variables](ecs-cluster/variables.tf), and define them in a `*.tfvars` file, e.g. `example.tfvars`.

Initialise the terraform directory passing (first time only), then run:

```sh
cd ecs-cluster
terraform init -backend-config=example.s3.tfbackend
terraform apply -var-file=example.tfvars
```
