variable "tg_arn" {
  description = "Target group"
  type        = string
}

variable "targets" {
  description = "Targets to Attach"
  type        = list(string)
}
