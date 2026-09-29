locals {
  # main tracks prod; any other branch name becomes the stage (e.g. dev → dev).
  stage = var.spacelift_stack_branch == "main" ? "prod" : var.spacelift_stack_branch

  application_name = "MSC OTC Agentic"

  # Prefix applied to every resource name in this stack.
  name_prefix = "msc-otc-agentic-${local.stage}"

  # Must match the Name tag on the account-owned VPC and the Network tag on its subnets.
  network_name = "${local.application_name} ${local.stage} - Account Owned"

  tags = {
    AppName     = "OTC Reinvention Agentic AI"
    Tower       = "MSC"
    Environment = local.stage
    Stack       = "endpoints"
  }
}