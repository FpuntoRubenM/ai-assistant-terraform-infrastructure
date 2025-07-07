/*
 * AI Assistant Infrastructure - Networking Module Outputs
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Output values from the networking module
 *              Provides VPC and subnet references for other modules
 */

# =============================================================================
# VPC OUTPUTS
# =============================================================================

# VPC ID for resource placement
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

# VPC CIDR block for security group rules
output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# =============================================================================
# SUBNET OUTPUTS
# =============================================================================

# Public subnet IDs for load balancers
output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

# Private subnet IDs for applications and databases
output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# Public subnet CIDR blocks for security rules
output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

# Private subnet CIDR blocks for security rules
output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

# =============================================================================
# GATEWAY OUTPUTS
# =============================================================================

# Internet Gateway ID
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# NAT Gateway IDs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

# NAT Gateway public IPs
output "nat_gateway_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = aws_eip.nat[*].public_ip
}

# =============================================================================
# VPC ENDPOINT OUTPUTS
# =============================================================================

# S3 VPC Endpoint ID
output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

# Secrets Manager VPC Endpoint ID
output "secretsmanager_vpc_endpoint_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

# VPC Endpoints security group ID
output "vpc_endpoints_security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}