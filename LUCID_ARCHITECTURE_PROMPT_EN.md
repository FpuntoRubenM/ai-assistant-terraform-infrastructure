# Lucid AI Prompt - Enterprise AI Assistant Architecture

**Author:** Ruben Martin  
**Date:** July 3, 2025  
**Project:** AI Assistant Infrastructure

---

## 🎨 LUCID AI PROMPT (ENGLISH VERSION)

```
Create a comprehensive AWS cloud architecture diagram for an Enterprise AI Assistant infrastructure with the following specifications:

TITLE: "Enterprise AI Assistant - AWS Cloud Architecture"
SUBTITLE: "Designed by Ruben Martin | Date: July 3, 2025"

OVERVIEW:
Design a multi-tier enterprise AI assistant architecture that supports voice and text processing, document analysis (PDF, Word, Excel, images, videos), semantic search with vector embeddings, role-based access control, and document generation capabilities.

MAIN ARCHITECTURAL COMPONENTS:

1. USER ACCESS & EDGE LAYER:
   - External users icon group (enterprise employees)
   - Corporate network representation
   - Public internet connection
   - AWS Route 53 DNS service
   - AWS WAF (Web Application Firewall) with shield icon
   - Amazon CloudFront CDN distribution
   - SSL/TLS certificate symbol

2. FRONTEND PRESENTATION LAYER:
   - Amazon S3 bucket (static website hosting)
   - CloudFront distribution connected to S3
   - Custom domain: "ai-assistant.company.com"
   - React/Angular web application symbol
   - Mobile responsive indicators

3. API GATEWAY & AUTHENTICATION LAYER:
   - Amazon API Gateway (REST API endpoints)
   - Amazon Cognito User Pool (user authentication)
   - Amazon Cognito Identity Pool (federated identities)
   - OAuth 2.0 / OpenID Connect flows
   - JWT token validation
   - Rate limiting and throttling indicators

4. NETWORK INFRASTRUCTURE LAYER:
   - Amazon VPC with CIDR block: 10.1.0.0/16
   - Three Availability Zones: us-east-1a, us-east-1b, us-east-1c
   - Public subnets: 10.1.1.0/24, 10.1.2.0/24, 10.1.3.0/24
   - Private subnets: 10.1.10.0/24, 10.1.20.0/24, 10.1.30.0/24
   - Internet Gateway (IGW)
   - NAT Gateways (3 instances, one per AZ)
   - Application Load Balancer (ALB) in public subnets
   - Network ACLs and Security Groups
   - VPC Endpoints for S3 and Secrets Manager

5. COMPUTE & APPLICATION LAYER:
   - Amazon ECS Fargate clusters (3 AZs)
   - AWS Lambda functions for serverless processing:
     * Document processor
     * Text analyzer
     * Voice processor
     * Response generator
   - Auto Scaling Groups with scaling policies
   - ECS Service Discovery
   - Application Load Balancer target groups

6. AI & MACHINE LEARNING SERVICES LAYER:
   - Amazon Bedrock foundation models:
     * Anthropic Claude 3 Sonnet
     * Anthropic Claude 3 Haiku
     * Cohere Embed English v3
     * Amazon Titan Embed Text v1
   - Amazon OpenSearch Service cluster (3 nodes, t3.medium.search)
   - Amazon Transcribe (speech-to-text)
   - Amazon Polly (text-to-speech)
   - Amazon Textract (document text extraction)
   - Amazon Rekognition (image/video analysis)
   - Vector embedding pipeline

7. DATA STORAGE & PERSISTENCE LAYER:
   - Amazon Aurora MySQL Serverless v2 cluster:
     * 2 instances across AZs
     * Auto-scaling: 2-16 ACUs
     * Read replicas
     * Performance Insights enabled
   - Amazon S3 Data Lake with organized buckets:
     * s3://ai-assistant-prod-raw-documents
     * s3://ai-assistant-prod-processed-documents
     * s3://ai-assistant-prod-embeddings
     * s3://ai-assistant-prod-user-uploads
     * s3://ai-assistant-prod-generated-documents
     * s3://ai-assistant-prod-backup
   - S3 Intelligent Tiering and Lifecycle policies
   - Amazon ElastiCache Redis cluster (caching layer)

8. SECURITY & COMPLIANCE LAYER:
   - AWS KMS (Key Management Service) with customer-managed keys
   - AWS Secrets Manager for credentials
   - AWS IAM roles and policies with least privilege
   - Security Groups with port-specific rules
   - AWS CloudTrail for audit logging
   - AWS Config for compliance monitoring
   - Encryption at rest and in transit indicators

9. MONITORING, LOGGING & OBSERVABILITY:
   - Amazon CloudWatch Logs (centralized logging)
   - Amazon CloudWatch Metrics and Dashboards
   - AWS X-Ray distributed tracing
   - Aurora Performance Insights
   - Custom application metrics
   - CloudWatch Alarms and SNS notifications

DATA FLOW PATTERNS:

PRIMARY USER FLOWS:
1. User Request Flow:
   Users → Route 53 → CloudFront → WAF → ALB → API Gateway → Lambda → Aurora/OpenSearch
   
2. Document Upload Flow:
   User → API Gateway → Lambda → S3 Raw → Textract/Rekognition → S3 Processed → OpenSearch Indexing
   
3. Voice Processing Flow:
   User → API Gateway → Lambda → Transcribe → Bedrock (Claude) → Polly → Response
   
4. Semantic Search Flow:
   Query → Lambda → Bedrock (Embeddings) → OpenSearch → Ranked Results → Response

VISUAL DESIGN REQUIREMENTS:

COLOR SCHEME BY LAYER:
- Edge/Frontend: Light Blue (#E3F2FD)
- API/Auth: Orange (#FFF3E0)
- Compute: Green (#E8F5E8)
- AI Services: Purple (#F3E5F5)
- Data Storage: Dark Blue (#E1F5FE)
- Security: Red (#FFEBEE)
- Monitoring: Yellow (#FFFDE7)
- Network: Gray (#F5F5F5)

ICON SPECIFICATIONS:
- Use official AWS service icons (latest version)
- Consistent sizing: Large icons for main services, medium for supporting services
- Include service logos for third-party integrations
- Add visual indicators for:
  * High Availability (multi-AZ symbol)
  * Auto Scaling (scaling arrows)
  * Encryption (lock symbols)
  * Real-time processing (clock/speed indicators)

CONNECTION TYPES:
- Solid arrows for synchronous calls
- Dashed arrows for asynchronous processing
- Thick arrows for high-volume data flows
- Color-coded arrows matching source service layer
- Bidirectional arrows where applicable

TECHNICAL ANNOTATIONS:

CAPACITY SPECIFICATIONS:
- Aurora MySQL: "Serverless v2, 2-16 ACUs, 99.99% SLA"
- OpenSearch: "3 nodes, t3.medium.search, 100GB storage"
- Lambda: "Auto-scaling, 15-minute timeout"
- ECS Fargate: "Auto-scaling, 4 vCPU, 8GB RAM per task"
- S3: "Intelligent Tiering, Lifecycle policies"
- CloudFront: "Global CDN, 216 edge locations"

SECURITY ANNOTATIONS:
- "End-to-end encryption with KMS"
- "WAF with OWASP Top 10 protection"
- "VPC isolation and security groups"
- "IAM roles with least privilege"

PERFORMANCE METRICS:
- "API latency: <500ms p95"
- "Document processing: <30 seconds"
- "Vector search: <100ms"
- "99.9% uptime SLA"

COST OPTIMIZATION FEATURES:
- "Serverless auto-scaling"
- "S3 Intelligent Tiering"
- "Aurora pause/resume"
- "Lambda pay-per-request"

LAYOUT AND COMPOSITION:

DIAGRAM STRUCTURE:
- Horizontal flow: Users (left) → Data Storage (right)
- Vertical layers: Edge (top) → Infrastructure (bottom)
- Logical grouping with rounded rectangles for each layer
- Clear separation between public and private components

LEGEND REQUIREMENTS:
- Service icon legend with descriptions
- Color coding explanation
- Connection type legend
- Security zone indicators
- Scaling and HA symbols

HEADER INFORMATION:
- Company/Project branding area
- Architecture title and subtitle
- Author: "Ruben Martin"
- Creation date: "July 3, 2025"
- Version: "v1.0"
- Last updated timestamp

FOOTER INFORMATION:
- Cost estimation: "Dev: $550/month, Prod: $3,300/month"
- Multi-cloud ready indicator
- Compliance standards: "SOC 2, GDPR ready"
- Contact information for architecture questions

ADDITIONAL TECHNICAL DETAILS:

NETWORK SPECIFICATIONS:
- VPC Peering connections (if applicable)
- Transit Gateway (if multi-VPC)
- Direct Connect (for hybrid connectivity)
- Bandwidth requirements between services

DISASTER RECOVERY:
- Cross-region backup indicators
- RTO/RPO specifications
- Backup and restore workflows

COMPLIANCE & GOVERNANCE:
- Data classification labels
- Audit trail indicators
- Compliance checkpoint symbols

Make the diagram enterprise-ready, technically accurate, and visually professional suitable for C-level presentations while maintaining technical depth for engineering teams.
```

---

## 🎯 KEY COMPONENTS VERIFICATION CHECKLIST

### AWS Services to Include:
✅ **Compute**: ECS Fargate, Lambda, Auto Scaling Groups  
✅ **Storage**: S3 (6 buckets), Aurora MySQL Serverless v2, ElastiCache Redis  
✅ **AI/ML**: Bedrock (4 models), OpenSearch (3 nodes), Transcribe, Polly, Textract, Rekognition  
✅ **Security**: Cognito, IAM, KMS, Secrets Manager, WAF, CloudTrail  
✅ **Networking**: VPC, Subnets, ALB, API Gateway, CloudFront, Route 53, NAT Gateways  
✅ **Monitoring**: CloudWatch (Logs, Metrics, Dashboards), X-Ray, Performance Insights  

### Critical Data Flows:
✅ **User Journey**: Users → CloudFront → S3 (Static content)  
✅ **API Calls**: Users → WAF → ALB → API Gateway → Lambda  
✅ **AI Processing**: Lambda → Bedrock → OpenSearch → Response  
✅ **Document Flow**: Upload → S3 → Textract → Processing → OpenSearch indexing  
✅ **Voice Flow**: Audio → Transcribe → Bedrock → Polly → Audio response  
✅ **Database**: Lambda → Aurora (transactional data)  

### Technical Specifications:
✅ **Network**: VPC 10.1.0.0/16, 3 AZs, public/private subnets  
✅ **Database**: Aurora Serverless v2, 2-16 ACUs, multi-AZ  
✅ **Search**: OpenSearch 3 nodes, t3.medium.search, 100GB each  
✅ **Domain**: ai-assistant.company.com  
✅ **Security**: End-to-end encryption, WAF, security groups  

---

## 📊 DIAGRAM CUSTOMIZATION OPTIONS

### For Different Audiences:

**EXECUTIVE VERSION:**
```
"Create a simplified executive overview focusing on business capabilities and cost benefits, remove technical specifications but keep security and compliance highlights"
```

**TECHNICAL DEEP-DIVE:**
```
"Add detailed technical specifications, port numbers, security group rules, and specific configuration parameters for each service"
```

**SECURITY FOCUS:**
```
"Emphasize security controls, compliance boundaries, data encryption flows, and audit trails throughout the architecture"
```

**COST OPTIMIZATION:**
```
"Highlight cost optimization features like serverless scaling, intelligent tiering, and resource right-sizing recommendations"
```

### Visual Variations:

**DARK THEME:**
```
"Create the same architecture using AWS dark theme colors suitable for dark backgrounds and modern presentations"
```

**SIMPLIFIED ICONS:**
```
"Use simplified, minimalist icons for a cleaner look suitable for high-level stakeholder presentations"
```

**DETAILED TECHNICAL:**
```
"Include detailed technical annotations, configuration parameters, and performance metrics on each component"
```

---

## 🚀 DEPLOYMENT SCENARIOS

### Multi-Environment View:
```
"Show development, staging, and production environments side by side with different sizing and configurations"
```

### Multi-Region Setup:
```
"Extend the architecture to show disaster recovery in a secondary AWS region with data replication flows"
```

### Hybrid Cloud:
```
"Add on-premises connectivity via AWS Direct Connect or VPN for hybrid cloud deployment scenario"
```

---

## 📋 FINAL VERIFICATION CHECKLIST

Before generating, ensure the prompt includes:

- [ ] Complete title with author and date
- [ ] All 9 architectural layers defined
- [ ] 50+ AWS services properly specified
- [ ] Color coding for different layers
- [ ] Official AWS icons requirement
- [ ] Data flow arrows with labels
- [ ] Technical specifications (CIDRs, capacities)
- [ ] Security zones with background colors
- [ ] Legend and footer requirements
- [ ] Multiple audience customization options

---

**Optimized English prompt for generating comprehensive Enterprise AI Assistant architecture in Lucid AI**