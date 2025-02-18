# rds.tf

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%"
}

resource "aws_db_instance" "rds" {
  identifier                   = "whitespace-${var.environment}"
  db_name                      = "whitespace"
  instance_class               = "db.t4g.small"
  allocated_storage            = 20
  engine                       = "postgres"
  engine_version               = "15"
  skip_final_snapshot          = true
  publicly_accessible          = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name         = aws_db_subnet_group.private_subnet_group.name
  username                     = "whitespace_${var.environment}"
  password                     = random_password.db_password.result
  backup_retention_period      = 7
  performance_insights_enabled = true

  lifecycle {
    ignore_changes = [
      password, # Ignore changes to the password attribute
    ]
  }
}
