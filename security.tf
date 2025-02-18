# Security Group for Load Balancer
resource "aws_security_group" "lb" {
  name        = "lb-security-group"
  description = "Security group for Load Balancer"
  vpc_id      = aws_vpc.main.id

  // Ingress rule allowing HTTP traffic from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for ECS
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-security-group"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  // Ingress rule allowing traffic from Load Balancer security group
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  // Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  // Ingress rule allowing traffic from ECS tasks security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  // Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
