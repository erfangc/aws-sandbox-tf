resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_instance.server.subnet_id]
}

resource "aws_lb_target_group" "tg" {
  target_type = "instance"
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_target_group_attachment" "tga" {
  target_group_arn = aws_lb_target_group.tg.arn
  port             = 80
  target_id        = aws_instance.server.id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb.arn
  protocol          = "TLS"
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
