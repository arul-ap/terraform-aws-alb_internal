
locals {
  targets_map = { for i, v in var.targets : i => v }
}

resource "aws_lb_target_group_attachment" "internal_alb" {
  for_each         = local.targets_map
  target_group_arn = var.tg_arn
  target_id        = each.value
}
