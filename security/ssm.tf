resource "aws_ssm_parameter" "lambda_role_arn" {
  for_each = var.lambda_roles

  name  = "/${local.name_prefix}/iam/lambda/${each.key}/role-arn"
  type  = "String"
  value = aws_iam_role.lambda[each.key].arn
}

resource "aws_ssm_parameter" "agentcore_role_arn" {
  for_each = var.agentcore_roles

  name  = "/${local.name_prefix}/iam/agentcore/${each.key}/role-arn"
  type  = "String"
  value = aws_iam_role.agentcore[each.key].arn
}
