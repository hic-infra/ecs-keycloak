resource "aws_wafv2_web_acl" "keycloak" {
  count = var.enable_waf ? 1 : 0

  name  = format("%s-waf", var.name)
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAF_Common_Protections"
    sampled_requests_enabled   = true
  }

  # We are managing rules via aws_wafv2_web_acl_rule resources
  lifecycle {
    ignore_changes = [rule]
  }
}

resource "aws_wafv2_web_acl_association" "keycloak" {
  count = var.enable_waf ? 1 : 0

  resource_arn = aws_lb.keycloak.arn
  web_acl_arn  = aws_wafv2_web_acl.keycloak[0].arn
}

# https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html
resource "aws_wafv2_web_acl_rule" "aws_baseline_core" {
  count = var.enable_waf ? 1 : 0

  name        = "aws-baseline-core"
  priority    = 3
  web_acl_arn = aws_wafv2_web_acl.keycloak[0].arn

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWS-ManagedRules-BaselineCore"
    sampled_requests_enabled   = true
  }
}

# https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html#aws-managed-rule-groups-baseline-known-bad-inputs
resource "aws_wafv2_web_acl_rule" "aws_bad_inputs" {
  count = var.enable_waf ? 1 : 0

  name        = "aws-bad-inputs"
  priority    = 7
  web_acl_arn = aws_wafv2_web_acl.keycloak[0].arn

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWS-ManagedRules-BadInputs"
    sampled_requests_enabled   = true
  }
}


# https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html#aws-managed-rule-groups-baseline-known-bad-inputs
resource "aws_wafv2_web_acl_rule" "aws_ip_reputation" {
  count = var.enable_waf ? 1 : 0

  name        = "aws-ip-reputation"
  priority    = 9
  web_acl_arn = aws_wafv2_web_acl.keycloak[0].arn

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesAmazonIpReputationList"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWS-ManagedRules-IpReputation"
    sampled_requests_enabled   = true
  }
}

# https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-use-case.html#aws-managed-rule-groups-use-case-sql-db
resource "aws_wafv2_web_acl_rule" "aws_sql_injection" {
  count = var.enable_waf ? 1 : 0

  name        = "aws-sql-injection"
  priority    = 13
  web_acl_arn = aws_wafv2_web_acl.keycloak[0].arn

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesSQLiRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWS-ManagedRules-SqlInjection"
    sampled_requests_enabled   = true
  }
}
