/*
 * AI Assistant Infrastructure - Networking Module
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Network infrastructure for the AI assistant
 *              Creates VPC, subnets, gateways, and routing for secure multi-tier architecture
 *
 * Components:
 * - VPC with public and private subnets across multiple AZs
 * - Internet Gateway for public subnet access
 * - NAT Gateways for private subnet outbound connectivity
 * - Route tables and security configurations
 * - VPC endpoints for AWS services (cost optimization)
 *
 * Security Features:
 * - Network isolation between tiers
 * - Private subnets for applications and databases
 * - Public subnets only for load balancers and NAT gateways
 */

# =============================================================================
# VPC AND CORE NETWORKING
# =============================================================================

# Main VPC for the AI assistant infrastructure
# Provides isolated network environment for all resources
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # IP address range for the VPC
  enable_dns_hostnames = true         # Enable DNS hostnames for resources
  enable_dns_support   = true         # Enable DNS resolution

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-vpc"
    Purpose = "AI assistant network infrastructure"
  })
}

# Internet Gateway for public subnet internet access
# Allows public subnets to communicate with the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # Attach to the main VPC

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-igw"
    Purpose = "Internet access for public subnets"
  })
}

# =============================================================================
# PUBLIC SUBNETS FOR LOAD BALANCERS AND NAT GATEWAYS
# =============================================================================

# Public subnets for internet-facing resources
# Host load balancers, NAT gateways, and bastion hosts
resource "aws_subnet" "public" {
  count = length(var.public_subnets) # Create one subnet per CIDR block

  vpc_id                  = aws_vpc.main.id                     # Parent VPC
  cidr_block              = var.public_subnets[count.index]     # Subnet IP range
  availability_zone       = var.availability_zones[count.index] # AZ for high availability
  map_public_ip_on_launch = true                                # Auto-assign public IPs

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
    Type = "Public"
    AZ   = var.availability_zones[count.index]
  })
}

# Elastic IPs for NAT Gateways
# Provides stable public IP addresses for outbound traffic
resource "aws_eip" "nat" {
  count = length(var.public_subnets) # One EIP per NAT Gateway

  domain = "vpc" # VPC-scoped Elastic IP

  # Ensure Internet Gateway exists before creating EIP
  depends_on = [aws_internet_gateway.main]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  })
}

# NAT Gateways for private subnet outbound connectivity
# Allows private resources to access internet while remaining private
resource "aws_nat_gateway" "main" {
  count = length(var.public_subnets) # One NAT Gateway per public subnet

  allocation_id = aws_eip.nat[count.index].id       # Elastic IP for the gateway
  subnet_id     = aws_subnet.public[count.index].id # Public subnet for placement

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gateway-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  })

  # Ensure Internet Gateway is ready before creating NAT Gateway
  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# PRIVATE SUBNETS FOR APPLICATIONS AND DATABASES
# =============================================================================

# Private subnets for application servers and databases
# No direct internet access for enhanced security
resource "aws_subnet" "private" {
  count = length(var.private_subnets) # Create one subnet per CIDR block

  vpc_id            = aws_vpc.main.id                     # Parent VPC
  cidr_block        = var.private_subnets[count.index]    # Subnet IP range
  availability_zone = var.availability_zones[count.index] # AZ for high availability

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
    Type = "Private"
    AZ   = var.availability_zones[count.index]
  })
}

# =============================================================================
# ROUTE TABLES AND ROUTING CONFIGURATION
# =============================================================================

# Route table for public subnets
# Routes traffic to Internet Gateway for internet access
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id # Associate with main VPC

  # Route all traffic (0.0.0.0/0) to Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"                  # All destinations
    gateway_id = aws_internet_gateway.main.id # Internet Gateway
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "Public"
  })
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public) # One association per public subnet

  subnet_id      = aws_subnet.public[count.index].id # Target subnet
  route_table_id = aws_route_table.public.id         # Public route table
}

# Route tables for private subnets
# Each private subnet gets its own route table for AZ-specific NAT routing
resource "aws_route_table" "private" {
  count = length(var.private_subnets) # One route table per private subnet

  vpc_id = aws_vpc.main.id # Associate with main VPC

  # Route all traffic to corresponding NAT Gateway in same AZ
  route {
    cidr_block     = "0.0.0.0/0"                          # All destinations
    nat_gateway_id = aws_nat_gateway.main[count.index].id # AZ-specific NAT Gateway
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
    Type = "Private"
    AZ   = var.availability_zones[count.index]
  })
}

# Associate private subnets with their respective route tables
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private) # One association per private subnet

  subnet_id      = aws_subnet.private[count.index].id      # Target subnet
  route_table_id = aws_route_table.private[count.index].id # Corresponding route table
}

# =============================================================================
# VPC ENDPOINTS FOR COST OPTIMIZATION
# =============================================================================

# VPC Endpoint for S3 (Gateway endpoint - no cost)
# Allows private access to S3 without internet routing
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id                                    # Target VPC
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3" # S3 service
  vpc_endpoint_type = "Gateway"                                          # Gateway endpoint type

  # Associate with private route tables
  route_table_ids = aws_route_table.private[*].id

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-s3-endpoint"
    Service = "S3"
    Type    = "Gateway"
  })
}

# VPC Endpoint for Secrets Manager (Interface endpoint)
# Provides private access to Secrets Manager for database credentials
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id             = aws_vpc.main.id                                                # Target VPC
  service_name       = "com.amazonaws.${data.aws_region.current.name}.secretsmanager" # Secrets Manager service
  vpc_endpoint_type  = "Interface"                                                    # Interface endpoint type
  subnet_ids         = aws_subnet.private[*].id                                       # Deploy in private subnets
  security_group_ids = [aws_security_group.vpc_endpoints.id]                          # Security group

  # Enable private DNS for easy service discovery
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-secretsmanager-endpoint"
    Service = "Secrets Manager"
    Type    = "Interface"
  })
}

# Security group for VPC endpoints
# Allows HTTPS access from private subnets
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.name_prefix}-vpc-endpoints-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for VPC endpoints"

  # Inbound rule: Allow HTTPS from private subnets
  ingress {
    from_port   = 443 # HTTPS port
    to_port     = 443
    protocol    = "tcp"               # TCP protocol
    cidr_blocks = var.private_subnets # Private subnet CIDR blocks
    description = "HTTPS access from private subnets"
  }

  # Outbound rule: Allow all outbound traffic
  egress {
    from_port   = 0 # All ports
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # All destinations
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-vpc-endpoints-sg"
    Purpose = "VPC endpoint access control"
  })
}

# Data source to get current AWS region
data "aws_region" "current" {}