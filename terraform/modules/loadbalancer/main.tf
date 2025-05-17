resource "aws_lb_target_group" "frontend" {
  name     = var.frontend_tg_name
  port     = var.frontend_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  protocol_version = "HTTP1"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_target_group" "backend" {
  name     = var.backend_tg_name
  port     = var.backend_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  protocol_version = "HTTP1"

  health_check {
    path                = "/api/students"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}


resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}