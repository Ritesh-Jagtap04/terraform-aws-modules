# The VPC and subnets are vended by the account network team — looked up by tag, never declared here.

# Looks up the account-owned VPC by its Name tag.
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.network_name]
  }
}

# TGW-routable Endpoints tier — dedicated subnet for interface VPC endpoints.
# Keeping endpoints in their own subnet tier isolates endpoint ENIs from application workloads.
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