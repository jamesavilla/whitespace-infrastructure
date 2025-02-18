# alb.tf

resource "aws_alb" "api" {
  name    = "whitespace-api-lb-${var.environment}"
  subnets = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb" "frontend" {
  name    = "whitespace-frontend-lb-${var.environment}"
  subnets = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "api" {
  name        = "whitespace-api-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_target_group" "frontend" {
  name        = "whitespace-frontend-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  stickiness {
    type = "lb_cookie"     # Use load balancer-generated cookies
    enabled = true         # Enable sticky sessions
    cookie_duration = 300  # Duration in seconds (e.g., 300 seconds = 5 minutes)
  }

  health_check {
    healthy_threshold   = "2"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = var.health_check_path_frontend
    unhealthy_threshold = "10"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "api" {
  load_balancer_arn = aws_alb.api.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "api_https" {
  load_balancer_arn = aws_alb.api.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.api_certificate.arn

  default_action {
    target_group_arn = aws_alb_target_group.api.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "frontend" {
  load_balancer_arn = aws_alb.frontend.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "frontend_https" {
  load_balancer_arn = aws_alb.frontend.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.frontend_certificate.arn

  default_action {
    target_group_arn = aws_alb_target_group.frontend.id
    type             = "forward"
  }
}

resource "aws_acm_certificate" "frontend_certificate" {
  domain_name       = var.frontend_domain
  validation_method = "DNS"

  subject_alternative_names = [
    var.public_frontend_domain
  ]

  tags = {
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_certificate" "frontend_listener_certificate" {
  listener_arn    = aws_alb_listener.frontend_https.arn
  certificate_arn = aws_acm_certificate.frontend_certificate.arn
}

resource "aws_acm_certificate" "api_certificate" {
  domain_name       = var.api_domain
  validation_method = "DNS"

  tags = {
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_certificate" "api_listener_certificate" {
  listener_arn    = aws_alb_listener.api_https.arn
  certificate_arn = aws_acm_certificate.api_certificate.arn
}