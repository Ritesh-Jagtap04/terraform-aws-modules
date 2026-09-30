module "s3" {
  source  = "us.spacelift.io/iac-acn-demo/s3/aws"
  version = "0.1.0"
  for_each = var.buckets

  # Bucket names are globally unique, so the account ID keeps them collision-free.
  name           = "${local.name_prefix}-${each.key}-${data.aws_caller_identity.current.account_id}"
  versioning     = each.value.versioning
  force_destroy  = each.value.force_destroy
  lifecycle_rule = each.value.lifecycle_rule
}
