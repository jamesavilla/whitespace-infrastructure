# ecs.tf

resource "aws_ecs_cluster" "api" {
  name = "whitespace-api-ecs-cluster-${var.environment}"
}

resource "aws_ecs_cluster_capacity_providers" "api_providers" {
  cluster_name = aws_ecs_cluster.api.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_cluster" "frontend" {
  name = "whitespace-frontend-ecs-cluster-${var.environment}"
}

resource "aws_ecs_cluster_capacity_providers" "frontend_providers" {
  cluster_name = aws_ecs_cluster.frontend.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "whitespace-api-ecs-task-definition-${var.environment}"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu_api
  memory                   = var.fargate_memory_api
  container_definitions = templatefile("whitespace-api.json.tpl", {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu_api
    fargate_memory = var.fargate_memory_api
    aws_region     = var.aws_region
    environment    = var.environment
    aws_account_id = var.aws_account_id
  })
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "whitespace-frontend-ecs-task-definition-${var.environment}"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory_frontend
  container_definitions = templatefile("whitespace-frontend.json.tpl", {
    app_image      = var.app_image_frontend
    app_port       = var.app_port_frontend
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory_frontend
    aws_region     = var.aws_region
    environment    = var.environment
    aws_account_id = var.aws_account_id
  })
}

resource "aws_ecs_service" "api" {
  name            = "whitespace-api-ecs-service-${var.environment}"
  cluster         = aws_ecs_cluster.api.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.app_count
  # launch_type     = "FARGATE"

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight = 100
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.api.id
    container_name   = "whitespace-api-${var.environment}"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.api_https, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment-secrets]
}

resource "aws_ecs_service" "frontend" {
  name            = "whitespace-frontend-ecs-service-${var.environment}"
  cluster         = aws_ecs_cluster.frontend.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.app_count_frontend
  # launch_type     = "FARGATE"

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight = 100
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.frontend.id
    container_name   = "whitespace-frontend-${var.environment}"
    container_port   = var.app_port_frontend
  }

  depends_on = [aws_alb_listener.frontend, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment-secrets]
}
