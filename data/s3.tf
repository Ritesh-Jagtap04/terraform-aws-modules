module "s3" {
  source   = "us.spacelift.io/iac-acn-demo/s3/aws"
  version  = "0.1.0"
  for_each = var.buckets

  # Bucket names are globally unique — account ID keeps them collision-free.
  bucket_name        = "${local.name_prefix}-${each.key}-${data.aws_caller_identity.current.account_id}"
  versioning_enabled = each.value.versioning
  force_destroy      = each.value.force_destroy
}
