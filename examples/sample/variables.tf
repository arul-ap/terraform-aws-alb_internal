variable "default_tags" {
  description = "AWS account level tags inherit to all resources"
  type        = map(string)
  default = {
    Organization = "ABC Company"
    Department   = "IT"
    CostCenter   = "IT"
  }
}