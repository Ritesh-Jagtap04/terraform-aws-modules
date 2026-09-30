# Used to resolve the current AWS account ID and region dynamically in resource ARNs and names.
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}