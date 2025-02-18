resource "aws_secretsmanager_secret" "api_secrets" {
  name = "whitespace-api-${var.environment}"
  description = "Secrets for whitespace api ${var.environment}"
}

resource "aws_secretsmanager_secret" "frontend_secrets" {
  name = "whitespace-frontend-${var.environment}"
  description = "Secrets for whitespace frontend ${var.environment}"
}

resource "aws_secretsmanager_secret_version" "api_secret_version" {
  secret_id     = aws_secretsmanager_secret.api_secrets.id
  secret_string = jsonencode({
    DB_HOST = aws_db_instance.rds.endpoint,
    DB_PORT = aws_db_instance.rds.port,
    DB_USER = aws_db_instance.rds.username,
    DB_PASSWORD = aws_db_instance.rds.password,
    DB_DATABASE = aws_db_instance.rds.db_name,
    DB_SSL_CA = "rds-ca-rsa2048-g1"
    APP_PORT = "8080",
    JWT_SECRET_KEY = "make-sure-this-secret-key-is-very-secure-in-prod",
    AWS_REGION = "us-east-1"
    DB_MAX_CONNECTIONS = 400,
    FRONTEND_HOST = "https://${var.frontend_domain}",
  })
}

resource "aws_secretsmanager_secret_version" "frontend_secret_version" {
  secret_id     = aws_secretsmanager_secret.frontend_secrets.id
  secret_string = jsonencode({
    NEXT_PUBLIC_API_HOST = "https://${var.api_domain}/api",
  })
}