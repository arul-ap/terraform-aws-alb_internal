

output "tg_arn" {
  description = "ARN of target groups"
  value       = { for k, v in var.target_groups : k => aws_lb_target_group.internal_alb[k].arn }
}
