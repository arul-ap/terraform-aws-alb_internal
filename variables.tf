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
  })
}

variable "alb_listeners_http" {
  description = "Map of listeners for internal ALB to support multiple ports (HTTP)"
  type = map(object({
    port       = number
    default_tg = string
  }))
}

variable "alb_listeners_https" {
  description = "Map of listeners for internal ALB to support multiple ports (HTTPS)"
  type = map(object({
    port             = number
    default_cert_arn = string
    default_tg       = string
  }))
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
  type = map(object({
    listener = string
    cert_arn = string
  }))
  default = {}
}
variable "rules" {
  description = "ALB rules"
  type = map(object({
    listener = string
    priority = number
    condition = object({
      host_header  = optional(list(string), [])
      path_pattern = optional(list(string), [])
      http_method  = optional(list(string), [])
      source_ip    = optional(list(string), [])
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
