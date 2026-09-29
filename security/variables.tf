variable "spacelift_stack_branch" {
  description = "(Required) Branch the Spacelift stack tracks. Injected by Spacelift as TF_VAR_spacelift_stack_branch."
  type        = string
}

variable "lambda_roles" {
  description = "Lambda execution roles to create, keyed by short name. The key becomes the role name suffix."
  type = map(object({
    vpc_access = optional(bool, true)
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.lambda_roles) : can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", k))])
    error_message = "Role keys become part of the role name, so they must be lowercase alphanumeric with single hyphens."
  }
}

variable "agentcore_roles" {
  description = "Bedrock AgentCore execution roles to create, keyed by short name. The key becomes the role name suffix."
  type = map(object({
    description = optional(string, "")
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.agentcore_roles) : can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", k))])
    error_message = "Role keys become part of the role name, so they must be lowercase alphanumeric with single hyphens."
  }
}
