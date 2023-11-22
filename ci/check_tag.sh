#!/usr/bin/bash
# If this is a git tag then check the container image tag has been updated
set -eu

if [[ "$GITHUB_REF" =~ ^refs/tags/ ]]; then
  GITHUB_TAG="${GITHUB_REF#refs/tags/}"
else
  echo "No tag detected"
  exit 0
fi

CONTAINER_TAG=$(grep ghcr.io/hic-infra/ecs-keycloak ecs-cluster/variables.tf | sed -re 's|.*:(.+)"|\1|')

if [[ "$GITHUB_TAG" != "$CONTAINER_TAG" ]]; then
  echo "ERROR: Container tag '$CONTAINER_TAG' does not match GitHub tag: '$GITHUB_TAG'"
  exit 1
fi
