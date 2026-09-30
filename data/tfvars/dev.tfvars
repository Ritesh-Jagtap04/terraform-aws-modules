# Values for the dev stage. Injected as -var-file by the Spacelift hooks.

buckets = {
  # Unstructured intake: order documents and email attachments.
  unstructured = {}

  # CRS batch staging. Transient, so no versioning.
  crs-staging = {
    versioning = false
  }

  # Agent outputs: extracted fields, reconciliation results, run summaries.
  # force_destroy so the bucket can be torn down without emptying versions first.
  agent-artifacts = {
    force_destroy = true
  }
}
