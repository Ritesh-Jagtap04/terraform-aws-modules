# ─────────────────────────────────────────────────────────────────────────────
# Lambda Execution Roles
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "lambda" {
  for_each = var.lambda_roles
  name     = "${local.name_prefix}-${each.key}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "LambdaAssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# CloudWatch Logs — create log streams and put log events.
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  for_each   = var.lambda_roles
  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC — describe/create/delete ENIs so Lambda can attach to the workload VPC.
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  for_each   = { for k, v in var.lambda_roles : k => v if v.vpc_access }
  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Least-privilege custom policy: Bedrock invocation, S3 workload buckets, SQS workload queues.
# Resource list includes both foundation-model/* and inference-profile/* so the policy covers
# runtime inference profile lookups (e.g. global.anthropic.claude-sonnet-4-6).
resource "aws_iam_policy" "lambda" {
  for_each = var.lambda_roles
  name     = "${local.name_prefix}-${each.key}-lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockInvoke"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/*",
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:inference-profile/*"
        ]
      },
      {
        Sid    = "S3WorkloadAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.name_prefix}-*-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::${local.name_prefix}-*-${data.aws_caller_identity.current.account_id}/*"
        ]
      },
      {
        Sid    = "SQSWorkloadAccess"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "arn:aws:sqs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${local.name_prefix}-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_custom" {
  for_each   = var.lambda_roles
  role       = aws_iam_role.lambda[each.key].name
  policy_arn = aws_iam_policy.lambda[each.key].arn
}

# ─────────────────────────────────────────────────────────────────────────────
# AgentCore Execution Roles
# ─────────────────────────────────────────────────────────────────────────────

# SourceAccount + SourceArn conditions prevent confused-deputy attacks.
resource "aws_iam_role" "agentcore" {
  for_each    = var.agentcore_roles
  name        = "${local.name_prefix}-${each.key}-agentcore"
  description = each.value.description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "BedrockAssumeRole"
      Effect    = "Allow"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
        ArnLike = {
          "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:agentcore/*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "agentcore" {
  for_each = var.agentcore_roles
  name     = "${local.name_prefix}-${each.key}-agentcore"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockModelInvocation"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/*",
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:inference-profile/*"
        ]
      },
      {
        Sid    = "BedrockKnowledgeBase"
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
      },
      {
        Sid      = "LambdaInvokeActionGroups"
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = "arn:aws:lambda:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:function:${local.name_prefix}-*"
      },
      {
        Sid    = "S3KnowledgeBaseRead"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.name_prefix}-*-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::${local.name_prefix}-*-${data.aws_caller_identity.current.account_id}/*"
        ]
      },
      {
        Sid      = "ECRGetToken"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRPullImage"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/${local.name_prefix}-*"
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/${local.name_prefix}-*"
      },
      {
        Sid    = "XRayTracing"
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "agentcore" {
  for_each   = var.agentcore_roles
  role       = aws_iam_role.agentcore[each.key].name
  policy_arn = aws_iam_policy.agentcore[each.key].arn
}
