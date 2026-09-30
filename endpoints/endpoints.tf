# ─────────────────────────────────────────────────────────────────────────────
# Security Group
# ─────────────────────────────────────────────────────────────────────────────

# Attached to every interface endpoint ENI.
# Only HTTPS inbound is needed — endpoints accept requests, they do not initiate connections.
resource "aws_security_group" "endpoints" {
  name        = "${local.name_prefix}-endpoints"
  description = "Allow HTTPS from within the VPC to interface endpoints."
  vpc_id      = data.aws_vpc.this.id
}

# Allows any resource inside the VPC CIDR to reach the endpoint on port 443.
resource "aws_vpc_security_group_ingress_rule" "endpoints_https" {
  security_group_id = aws_security_group.endpoints.id
  description       = "HTTPS from VPC CIDR"
  cidr_ipv4         = data.aws_vpc.this.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# ─────────────────────────────────────────────────────────────────────────────
# Interface VPC Endpoints
# ─────────────────────────────────────────────────────────────────────────────

# Creates one interface endpoint per service in var.interface_endpoints.
# private_dns_enabled = true means AWS SDK calls (e.g. bedrock-runtime.ap-south-1.amazonaws.com)
# resolve to the private endpoint IP inside the VPC — no code changes needed in Lambda or AgentCore.
resource "aws_vpc_endpoint" "this" {
  for_each = toset(var.interface_endpoints)

  vpc_id              = data.aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.endpoints.ids
  security_group_ids  = [aws_security_group.endpoints.id]

  # Overrides the public DNS for this service with a private Route 53 alias
  # so traffic stays within the VPC without any application-level changes.
  private_dns_enabled = true
}