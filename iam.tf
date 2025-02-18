resource "aws_iam_role" "ecs_task_execution_role" {
  name = "whitespace-ecs-task-execution-role-${var.environment}"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment-secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy_document" "ecs_auto_scale_role" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

# ECS auto scale role
resource "aws_iam_role" "ecs_auto_scale_role" {
  name               = "whitespace-ecs-auto-scale-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_auto_scale_role.json
}

# ECS auto scale role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_auto_scale_role" {
  role       = aws_iam_role.ecs_auto_scale_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_role" "ecs_deploy_role" {
  name = "whitespace-ecs-deploy-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::870534772806:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:jamesavilla/*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com",
            "codepipeline.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_deploy_policy_attachment" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_policy" "assume_role_policy" {
  name        = "assume-role-policy-${var.environment}"
  description = "Policy for assuming role with Web Identity"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRoleWithWebIdentity"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_policy_attachment" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = aws_iam_policy.assume_role_policy.arn
}

# Create an IAM policy that allows pulling images from ECR
resource "aws_iam_policy" "ecr_read_policy" {
  name        = "ECRReadPolicy-${var.environment}"
  description = "Allows read access to Amazon ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "iam:PassRole",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "secretsmanager:*",
        "ses:SendEmail",
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy" "s3_organization_assets_access_policy" {
  name        = "s3-access-policy-${var.environment}"
  description = "Policy for accessing S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      Resource = aws_s3_bucket.organization_assets.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecr_read_write_policy" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = aws_iam_policy.ecr_read_policy.arn
}

# Attach the IAM policy to the IAM role used by ECS tasks
resource "aws_iam_role_policy_attachment" "attach_ecr_read_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecr_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.s3_organization_assets_access_policy.arn
}