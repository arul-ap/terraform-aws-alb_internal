variable "condition" {
  description = "Rule condition"
  type = object({
    host_header  = optional(list(string), [])
    path_pattern = optional(list(string), [])
    http_method  = optional(list(string), [])
    source_ip    = optional(list(string), [])
  })
}
variable "target_group_arn" {
  description = "Rule target"
  type        = string
}

variable "alb_listener_arn" {
  description = "LB listener ARN"
  type        = string
}

variable "priority" {
  description = "Rule priority"
  type        = number
}
