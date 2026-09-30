variable "spacelift_stack_branch" {
  description = "(Required) Branch the Spacelift stack tracks. Injected by Spacelift as TF_VAR_spacelift_stack_branch."
  type        = string
}

variable "interface_endpoints" {
  description = <<-EOT
    AWS service short names to expose as interface VPC endpoints.
    Each value is appended to "com.amazonaws.<region>." to form the full service name.
    S3 and DynamoDB are excluded — they use free gateway endpoints vended by the account network.
  EOT
  type        = list(string)
  default     = []
}