# outputs.tf

output "alb_hostname_api" {
  value = aws_alb.api.dns_name
}

output "alb_hostname_frontend" {
  value = aws_alb.frontend.dns_name
}

output "rds_hostname" {
  value = aws_db_instance.rds.endpoint
}

output "github_action_deployment_role" {
  value = aws_iam_role.ecs_deploy_role.arn
}