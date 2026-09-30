# data

Aurora PostgreSQL Serverless v2, DynamoDB, S3, and GraphDB on ECS Fargate + EFS.

Sits in the isolated Data tier. Security groups come from the `security` stack via SSM.
Kept separate from `agents` so agent-runtime churn can't touch persistent storage.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 7.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_s3"></a> [s3](#module\_s3) | spacelift.io/mondelez-ctiso/terraform-aws-s3/aws | ~> 1.3 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_subnet.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | S3 buckets to create, keyed by short name. The key becomes the bucket name suffix. | <pre>map(object({<br/>    versioning     = optional(bool, true)<br/>    force_destroy  = optional(bool, false)<br/>    lifecycle_rule = optional(any, [])<br/>  }))</pre> | `{}` | no |
| <a name="input_spacelift_stack_branch"></a> [spacelift\_stack\_branch](#input\_spacelift\_stack\_branch) | (Required) Branch the Spacelift stack tracks. Injected by Spacelift as TF\_VAR\_spacelift\_stack\_branch. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
