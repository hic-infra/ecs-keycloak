output "dnsname" {
  value = aws_lb.keycloak.dns_name
}

output "keycloak-initial-password" {
  value = random_string.initial-keycloak-password.result
}