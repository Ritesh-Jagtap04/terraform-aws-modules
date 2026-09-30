# The VPC and subnets are vended - looked up here, never declared.

# tflint-ignore: terraform_unused_declarations
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.network_name]
  }
}

# Isolated Data tier.
# tflint-ignore: terraform_unused_declarations
data "aws_subnets" "data" {
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }

  filter {
    name   = "tag:SubnetName"
    values = ["Data"]
  }

  filter {
    name   = "tag:Network"
    values = [local.network_name]
  }
}

# Subnet objects, for rules that need CIDRs rather than IDs.
# tflint-ignore: terraform_unused_declarations
data "aws_subnet" "data" {
  for_each = toset(data.aws_subnets.data.ids)
  id       = each.value
}
