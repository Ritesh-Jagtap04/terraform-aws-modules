# Published for downstream stacks (agents, data) that need to attach the endpoints
# security group to their resources or reference it in security group rules.
resource "aws_ssm_parameter" "endpoint_sg_id" {
  name  = "/${local.name_prefix}/endpoints/security-group-id"
  type  = "String"
  value = aws_security_group.endpoints.id
}