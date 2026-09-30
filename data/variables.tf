variable "spacelift_stack_branch" {
  description = "(Required) Branch the Spacelift stack tracks. Injected by Spacelift as TF_VAR_spacelift_stack_branch."
  type        = string
}

variable "buckets" {
  description = "S3 buckets to create, keyed by short name. The key becomes the bucket name suffix."
  type = map(object({
    versioning     = optional(bool, true)
    force_destroy  = optional(bool, false)
    lifecycle_rule = optional(any, [])
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.buckets) : can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", k))])
    error_message = "Bucket keys become part of the bucket name, so they must be lowercase alphanumeric with single hyphens."
  }
}

