# security

Workload IAM execution roles, Secrets Manager, and **all** workload security groups.

Applies first. Security groups live here (not in `data`/`agents`) so the cross-tier SG
references don't form a dependency cycle - publish their IDs to SSM and read them elsewhere.

Not here: KMS keys (reference the central CMKs, never create), SSO `custom_roles` (vended),
VPC/subnets (vended - see `network.tf`).

## IAM Roles

### Lambda Execution Roles (`var.lambda_roles`)

One role per Lambda function, keyed by short name. Each role receives:

| Policy | Type | Purpose |
| ------ | ---- | ------- |
| `AWSLambdaBasicExecutionRole` | AWS Managed | CloudWatch Logs — create log streams, put log events |
| `AWSLambdaVPCAccessExecutionRole` | AWS Managed | VPC ENI management (attached when `vpc_access = true`, the default) |
| `{name_prefix}-{key}-lambda` | Customer Managed | Least-privilege: Bedrock model invocation, S3 workload buckets, SQS workload queues |

Resource ARNs in the custom policy are scoped to the account, region, and `msc-otc-agentic-{stage}-*` name prefix — no cross-account or cross-prefix access.

### AgentCore Execution Roles (`var.agentcore_roles`)

One role per Bedrock AgentCore agent, keyed by short name. Trust policy includes `SourceAccount` and `SourceArn` conditions to prevent confused-deputy attacks.

| Policy | Type | Purpose |
| ------ | ---- | ------- |
| `{name_prefix}-{key}-agentcore` | Customer Managed | Bedrock model invocation + knowledge base retrieval, Lambda action group invocation, S3 knowledge base read |

All resources scoped to `msc-otc-agentic-{stage}-*` within the account and region.

### Naming convention

```
msc-otc-agentic-{stage}-{key}-lambda      # Lambda execution role + policy
msc-otc-agentic-{stage}-{key}-agentcore   # AgentCore execution role + policy
```

`stage` is derived from `var.spacelift_stack_branch`: `main` → `prod`, any other branch → the branch name itself.

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

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.agentcore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.agentcore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.agentcore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_spacelift_stack_branch"></a> [spacelift\_stack\_branch](#input\_spacelift\_stack\_branch) | (Required) Branch the Spacelift stack tracks. Injected by Spacelift as TF\_VAR\_spacelift\_stack\_branch. | `string` | n/a | yes |
| <a name="input_lambda_roles"></a> [lambda\_roles](#input\_lambda\_roles) | Lambda execution roles to create, keyed by short name. The key becomes the role name suffix. | <pre>map(object({<br/>    vpc_access = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_agentcore_roles"></a> [agentcore\_roles](#input\_agentcore\_roles) | Bedrock AgentCore execution roles to create, keyed by short name. The key becomes the role name suffix. | <pre>map(object({<br/>    description = optional(string, "")<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
