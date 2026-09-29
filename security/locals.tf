locals {
  # main tracks prod; any other branch is its own stage.
  # replace "/" so that feature branch names (e.g. feat/security) are valid in IAM resource names.
  stage = var.spacelift_stack_branch == "main" ? "prod" : replace(var.spacelift_stack_branch, "/", "-")

  application_name = "MSC OTC Agentic"
  name_prefix      = "msc-otc-agentic-${local.stage}"

  # VPC Name tag, and the Network tag on all of its subnets.
  network_name = "${local.application_name} ${local.stage} - Account Owned"

  tags = {
    AppName     = "OTC Reinvention Agentic AI"
    Tower       = "MSC"
    Environment = local.stage
    Stack       = "security"
  }
}
