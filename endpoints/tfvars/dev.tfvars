# Values for the dev stage. Injected as -var-file by the Spacelift hooks.
# Interface endpoints for the dev stage.
# Each service listed here gets a private ENI in the Endpoints subnet,
# so Lambda and AgentCore can reach AWS APIs without an internet or NAT gateway.
# S3 and DynamoDB are excluded — gateway endpoints are already vended by the account network.

interface_endpoints = [
  "bedrock-runtime",        # Bedrock model invocation (Lambda + AgentCore)
  "bedrock-agent-runtime",  # Bedrock Knowledge Base retrieve (AgentCore)
  "lambda",                 # AgentCore invoking tool Lambdas
  "ecr.api",                # ECR image metadata (AgentCore container pull)
  "ecr.dkr",                # ECR image layers (AgentCore container pull)
  "sqs",                    # Lambda sending/receiving SQS messages
  "logs",                   # CloudWatch log delivery from Lambda and AgentCore
  "ssm",                    # SSM parameter reads across all stacks
  "xray",                   # Distributed tracing from Lambda and AgentCore
  "execute-api",            # Private API Gateway invocation over TGW
]