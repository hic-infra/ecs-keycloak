# https://github.com/terraform-aws-modules/terraform-aws-ecs
# https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/
# https://github.com/finleap/tf-ecs-fargate-tmpl

resource "aws_kms_key" "ecs-logs" {
  description             = "ecs-logs"
  deletion_window_in_days = 30
}

resource "aws_cloudwatch_log_group" "ecs-logs" {
  name              = var.name
  retention_in_days = 3653
}

resource "aws_ecs_cluster" "ecs" {
  name = var.name

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs-logs.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs-logs.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.ecs.name

  # capacity_providers = ["FARGATE", "FARGATE-SPOT"]
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
