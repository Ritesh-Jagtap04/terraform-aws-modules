# The VPC and subnets are vended - looked up here, never declared.

# tflint-ignore: terraform_unused_declarations
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.network_name]
  }
}

# TGW-routable Endpoints tier.
# tflint-ignore: terraform_unused_declarations
data "aws_subnets" "endpoints" {
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }

  filter {
    name   = "tag:SubnetName"
    values = ["Endpoints"]
  }

  filter {
    name   = "tag:Network"
    values = [local.network_name]
  }
}
