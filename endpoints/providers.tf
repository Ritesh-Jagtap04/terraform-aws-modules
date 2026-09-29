provider "aws" {
  region = "ap-south-1"

  # Applies the tags defined in locals.tf to every resource in this stack.
  default_tags {
    tags = local.tags
  }
}