provider "aws" {
  region = "ap-south-1"

  # Module-created resources cannot take a tags argument, so tag at the provider.
  default_tags {
    tags = local.tags
  }
}
