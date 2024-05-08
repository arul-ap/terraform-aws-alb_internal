
resource "aws_lb_listener_rule" "internal_alb" {
  listener_arn = var.alb_listener_arn
  priority     = var.priority
  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
  condition {

    dynamic "host_header" {
      for_each = var.condition.host_header
      content {
        values = [host_header.value]
      }
    }
    dynamic "path_pattern" {
      for_each = var.condition.path_pattern
      content {
        values = [path_pattern.value]
      }
    }
    dynamic "http_request_method" {
      for_each = var.condition.http_method
      content {
        values = [http_request_method.value]
      }
    }
    dynamic "source_ip" {
      for_each = var.condition.source_ip
      content {
        values = [source_ip.value]
      }
    }
  }
}
