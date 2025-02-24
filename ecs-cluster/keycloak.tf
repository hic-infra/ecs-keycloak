data "aws_caller_identity" "current" {}

locals {
  container-port    = 8443
  management-port   = 9000
  keycloak-hostname = var.keycloak-hostname == "" ? aws_lb.keycloak.dns_name : var.keycloak-hostname

  vpc_id          = var.vpc-id == "" ? module.vpc[0].vpc_id : var.vpc-id
  public_subnets  = length(var.public-subnets) == 0 ? module.vpc[0].public_subnets : var.public-subnets
  private_subnets = length(var.private-subnets) == 0 ? module.vpc[0].private_subnets : var.private-subnets
}

resource "random_password" "db-password" {
  length  = 20
  special = false
}

resource "random_string" "initial-keycloak-password" {
  length = 20
}

# Networking

resource "aws_security_group" "rds" {
  name   = "${var.name}-sg-rds"
  vpc_id = local.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-task-keycloak.id]
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.name}-sg-alb"
  vpc_id = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.lb-cidr-blocks-in
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.lb-cidr-blocks-in
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs-task-keycloak" {
  name   = "${var.name}-sg-task-keycloak"
  vpc_id = local.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = local.container-port
    to_port         = local.container-port
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    protocol        = "tcp"
    from_port       = local.management-port
    to_port         = local.management-port
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load balancer logs
resource "aws_s3_bucket" "alb-logs" {
  bucket_prefix = "${var.name}-logs-"
}

data "aws_iam_policy_document" "alb-logs" {
  statement {
    principals {
      type        = var.loadbalancer-logging-iam-principal.type
      identifiers = [var.loadbalancer-logging-iam-principal.identifier]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.alb-logs.arn}/access-logs/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "alb-logs" {
  bucket = aws_s3_bucket.alb-logs.id
  policy = data.aws_iam_policy_document.alb-logs.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb-logs-encryption" {
  bucket = aws_s3_bucket.alb-logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "alb-logs" {
  bucket = aws_s3_bucket.alb-logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb-logs" {
  bucket = aws_s3_bucket.alb-logs.id
  rule {
    id = "delete-access-logs-${var.expire-access-logs-days}-days"
    filter {
      prefix = "access-logs/"
    }
    expiration {
      days = var.expire-access-logs-days
    }
    status = "Enabled"
  }
}

# Load balancer

resource "aws_lb" "keycloak" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.public_subnets

  enable_deletion_protection = true

  preserve_host_header = true

  access_logs {
    bucket  = aws_s3_bucket.alb-logs.id
    prefix  = "access-logs"
    enabled = true
  }

  depends_on = [
    # ELB writes a test file to bucket/access-logs so the policy must be in place
    aws_s3_bucket_policy.alb-logs
  ]
}

resource "aws_alb_target_group" "keycloak" {
  name        = "${var.name}-tg"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTPS"
    matcher             = "200"
    timeout             = "5"
    path                = "/health"
    port                = local.management-port
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.keycloak.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      host        = local.keycloak-hostname
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.keycloak.id
  port              = 443
  protocol          = "HTTPS"

  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.loadbalancer-certificate-arn

  default_action {
    target_group_arn = aws_alb_target_group.keycloak.id
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "https_redirect_canonical" {
  listener_arn = aws_alb_listener.https.arn
  count        = var.keycloak-hostname == "" ? 0 : 1

  action {
    type = "redirect"
    redirect {
      host        = local.keycloak-hostname
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [aws_lb.keycloak.dns_name]
    }
  }
}

# PostgreSQL

resource "aws_db_parameter_group" "keycloak" {
  name   = "${var.name}-keycloak"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_subnet_group" "keycloak" {
  name       = "${var.name}-keycloak"
  subnet_ids = local.private_subnets
}

resource "aws_db_instance" "keycloak" {
  identifier            = "keycloak-1"
  instance_class        = var.db-instance-type
  allocated_storage     = 5
  max_allocated_storage = 20
  engine                = "postgres"
  # TODO: try serverless?
  # engine = "aurora-postgresql"
  # auto_minor_version_upgrade defaults to True, so this will be auto-upgraded to the  most recent 14.*
  engine_version    = "14"
  storage_encrypted = true

  # By default changes are queued up for the maintenance window
  # If keycloak desired-count=0 then we can apply straight away
  apply_immediately = (var.desired-count < 1)

  # Max 35 days https://aws.amazon.com/rds/features/backup/
  backup_retention_period  = 35
  delete_automated_backups = false
  deletion_protection      = true

  db_name                = var.db-name
  username               = var.db-username
  password               = random_password.db-password.result
  db_subnet_group_name   = aws_db_subnet_group.keycloak.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.keycloak.name
  publicly_accessible    = false
  skip_final_snapshot    = false

  snapshot_identifier = var.db-snapshot-identifier

  lifecycle {
    prevent_destroy = true
  }
}

# IAM

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}


# resource "aws_iam_role" "ecs_task_role" {
#   name = "${var.name}-ecsTaskRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#         Effect = "Allow"
#       }
#     ]
#   })

#   inline_policy {
#     name = "rds-keycloak"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           # TODO: Restrict permissions
#           Action   = ["rds:*"]
#           Effect   = "Allow"
#           Resource = aws_db_instance.keycloak.arn
#         },
#       ]
#     })
#   }
# }

# Keycloak

resource "aws_ecs_task_definition" "keycloak" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # 1024 cpu units = 1 vCPU
  cpu                = 512
  memory             = 1024
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn      = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name  = "${var.name}-container"
    image = var.keycloak-image
    # command   = ["start", "--optimized"]
    essential = true
    environment = [
      # https://www.keycloak.org/server/all-config
      {
        name  = "KC_DB_URL"
        value = "jdbc:postgresql://${aws_db_instance.keycloak.endpoint}/${aws_db_instance.keycloak.db_name}"
      },
      {
        name  = "KC_DB_USERNAME"
        value = var.db-username
      },
      {
        name  = "KC_DB_PASSWORD"
        value = random_password.db-password.result
      },
      {
        name  = "KEYCLOAK_ADMIN"
        value = "admin"
      },
      # Only used for initial setup
      {
        name  = "KEYCLOAK_ADMIN_PASSWORD"
        value = random_string.initial-keycloak-password.result
      },
      {
        name  = "KC_HOSTNAME"
        value = local.keycloak-hostname
      },
      # https://www.keycloak.org/server/reverseproxy
      # AWS load balancers set X-Forwarded not Forwarded
      # https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html
      {
        name  = "KC_PROXY_HEADERS"
        value = "xforwarded"
      },
      {
        name  = "KC_LOG_LEVEL"
        value = var.keycloak-loglevel
      },
    ]
    portMappings = [{
      protocol      = "tcp"
      containerPort = local.container-port
      hostPort      = local.container-port
      }, {
      protocol      = "tcp"
      containerPort = local.management-port
      hostPort      = local.management-port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.region
        awslogs-group         = aws_cloudwatch_log_group.ecs-logs.name
        awslogs-stream-prefix = "keycloak"
      }
    }
  }])
}

resource "aws_ecs_service" "keycloak" {
  name                               = "${var.name}-service"
  cluster                            = aws_ecs_cluster.ecs.id
  task_definition                    = aws_ecs_task_definition.keycloak.arn
  desired_count                      = var.desired-count
  deployment_minimum_healthy_percent = (var.desired-count < 1) ? 0 : 100
  deployment_maximum_percent         = max(100, var.desired-count * 200)
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups = [
      aws_security_group.rds.id,
      aws_security_group.ecs-task-keycloak.id
    ]
    subnets = local.private_subnets
    # TODO: Setting this to False means the image can't be pulled. Why? It works in K8s.
    # assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.keycloak.arn
    container_name   = "${var.name}-container"
    container_port   = local.container-port
  }

  # Java applications can be very slow to start
  health_check_grace_period_seconds = 180

  # lifecycle {
  #   ignore_changes = [desired_count]
  # }
}
