# Changelog

## 2.2.1 - 2025-08-06

([full changelog](https://github.com/hic-infra/ecs-keycloak/compare/2.2.0...2.2.1))

- Bump keycloak/keycloak from 26.1.2 to 26.3.2 in /container [#39](https://github.com/hic-infra/ecs-keycloak/pull/39)
- Bump actions/setup-python from 4 to 5 [#32](https://github.com/hic-infra/ecs-keycloak/pull/32)

## 2.2.0 - 2025-02-24

([full changelog](https://github.com/hic-infra/ecs-keycloak/compare/2.1.0...2.2.0))

- Bump keycloak/keycloak from 26.1.1 to 26.1.2 in /container [#30](https://github.com/hic-infra/ecs-keycloak/pull/30)
- Add access logging for load-balancer [#29](https://github.com/hic-infra/ecs-keycloak/pull/29)
- Include all dependabot updates, prevent concurrent CI builds/pushes [#28](https://github.com/hic-infra/ecs-keycloak/pull/28)
- Keycloak 26.1.1 [#22](https://github.com/hic-infra/ecs-keycloak/pull/22)
- Switch to loadbalancer ELBSecurityPolicy-TLS13-1-2-2021-06 #21 [#21](https://github.com/hic-infra/ecs-keycloak/pull/21)

## 2.1.0 - 2024-11-12

([full changelog](https://github.com/hic-infra/ecs-keycloak/compare/2.0.0...2.1.0))

- Update keycloak 26.0.5 [#19](https://github.com/hic-infra/ecs-keycloak/pull/19)

## 2.0.0 - 2024-07-16

([full changelog](https://github.com/hic-infra/ecs-keycloak/compare/1.0.0...2.0.0))

- Keycloak 25.0.1, update Terraform deps [#17](https://github.com/hic-infra/ecs-keycloak/pull/17)
- Fix empty check of `var.{public,private}-subnets`, delay health check, 2.0.0-beta.3 [#16](https://github.com/hic-infra/ecs-keycloak/pull/16)
- Release 2.0.0-beta.2 [#15](https://github.com/hic-infra/ecs-keycloak/pull/15)
- Add `terraform {backend s3}` back [#14](https://github.com/hic-infra/ecs-keycloak/pull/14)
- Release 2.0.0-beta.1 [#13](https://github.com/hic-infra/ecs-keycloak/pull/13)
- Optionally use existing VPC. Upgrade Keycloak to 24.0.2 [#12](https://github.com/hic-infra/ecs-keycloak/pull/12)
- Move CHANGELOG to top level, update tag in variables.tf [#11](https://github.com/hic-infra/ecs-keycloak/pull/11)

## 1.0.0 - 2023-11-23

First full release

- Keycloak 22.05
