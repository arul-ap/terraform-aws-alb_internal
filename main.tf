locals {
  name-prefix = lower("${var.org}-${var.proj}-${var.env}") // prefix for naming resources
}

data "aws_region" "current" {}
resource "aws_lb" "internal" {
  name            = "${local.name-prefix}-${var.alb.name}"
  internal        = true
  subnets         = var.alb.subnet_id
  security_groups = var.alb.security_group_id
}

resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  protocol          = "HTTPS"
  port              = "443"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-3-2021-06"
  certificate_arn   = var.alb.default_cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_alb[var.alb.default_tg].arn
  }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  protocol          = "HTTP"
  port              = "80"
  default_action {
    type             = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "internal_alb" {
  for_each    = var.target_groups
  name        = "${local.name-prefix}-${each.key}"
  target_type = each.value.type
  vpc_id      = each.value.vpc_id
  protocol    = each.value.protocol
  port        = each.value.port
}

locals {
  tg_with_targets = { for k, v in var.target_groups : k => v if v.target_id != [] }
}

module "tg_attach" {
  for_each = local.tg_with_targets
  source   = "./modules/tg_attach"
  tg_arn   = aws_lb_target_group.internal_alb[each.key].arn
  targets  = each.value.target_id
}

resource "aws_lb_listener_certificate" "alb_internal" {
  for_each        = var.certs_arn
  listener_arn    = aws_lb_listener.internal.arn
  certificate_arn = each.value
}
locals {
  forward_rules  = { for k, v in var.rules : k => v if v.action.action_type == "forward" }
  redirect_rules = { for k, v in var.rules : k => v if v.action.action_type == "redirect" }
}

module "redirect" {
  for_each         = local.redirect_rules
  source           = "./modules/redirect_rule"
  alb_listener_arn = aws_lb_listener.internal.arn
  priority         = each.value.priority
  condition        = each.value.condition
  redirect         = each.value.action.redirect
}

module "forward" {
  for_each         = local.forward_rules
  source           = "./modules/forward_rule"
  alb_listener_arn = aws_lb_listener.internal.arn
  priority         = each.value.priority
  condition        = each.value.condition
  target_group_arn = aws_lb_target_group.internal_alb[each.value.target_group].arn
}
