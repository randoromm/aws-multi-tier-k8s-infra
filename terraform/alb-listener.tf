resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = module.alb.arn
  port              = 80
  protocol          = "HTTP"

  #  default_action {
  #    type             = "forward"
  #    target_group_arn = aws_lb_target_group.frontend_tg.arn
  #  }

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hello, ALB is working!"
      status_code  = "200"
    }
  }
}
