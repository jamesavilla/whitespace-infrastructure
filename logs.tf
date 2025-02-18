# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "api_log_group" {
  name              = "whitespace-api-${var.environment}"
  retention_in_days = 30

  tags = {
    Name = "whitespace-api-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "api_log_stream" {
  name           = "whitespace-api-log-stream-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.api_log_group.name
}

resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name              = "whitespace-frontend-${var.environment}"
  retention_in_days = 30

  tags = {
    Name = "whitespace-frontend-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "frontend_log_stream" {
  name           = "whitespace-frontend-log-stream-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.frontend_log_group.name
}