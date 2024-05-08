variable "org" {
  description = "Organization code to inlcude in resource names"
  type        = string
}
variable "proj" {
  description = "Project code to include in resource names"
  type        = string
}
variable "env" {
  description = "Environment code to include in resource names"
  type        = string
}
variable "alb" {
  description = "ALB details"
  type = object({
    name              = string
    subnet_id         = list(string)
    security_group_id = list(string)
    default_cert_arn  = string
    default_tg        = string
  })
}
variable "target_groups" {
  description = "Target Groups"
  type = map(object({
    vpc_id    = string
    type      = optional(string, "instance")
    protocol  = string
    port      = number
    target_id = list(string)
  }))
}
variable "certs_arn" {
  description = "Additional Certificates to configure into ALB"
  type        = map(string)
  default     = {}
}
variable "rules" {
  description = "ALB rules"
  type = map(object({
    priority = number
    condition = object({
      host_header  = optional(string, null)
      path_pattern = optional(string, null)
      http_method  = optional(string, null)
      source_ip    = optional(string, null)
    })
    action = object({
      action_type  = string
      target_group = optional(string, null)
      redirect = optional(object({
        host        = optional(string)
        path        = optional(string)
        port        = optional(number)
        protocol    = optional(string)
        status_code = string
      }))
    })
  }))
  default = {}
}
