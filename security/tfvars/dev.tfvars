# Values for the dev stage. Injected as -var-file by the Spacelift hooks.

lambda_roles = {
  # Orchestration Lambda: invokes Bedrock agents, reads/writes S3, sends to SQS.
  agent-runner = {}

  # Document ingestion Lambda: reads raw files from S3 and extracts structured fields.
  document-ingestion = {}
}

agentcore_roles = {
  # Main OTC orchestrator agent — coordinates document processing and reconciliation sub-agents.
  otc-orchestrator = {}
}
