# Lucid AI Optimized Prompt - Enterprise AI Assistant Architecture

**Author:** Ruben Martin  
**Date:** July 3, 2025  
**Project:** AI Assistant Infrastructure  
**Version:** Optimized for Lucid AI capabilities

---

## 🎨 OPTIMIZED LUCID AI PROMPT

```
Create a comprehensive AWS cloud architecture diagram for an Enterprise AI Assistant infrastructure.

TITLE: "Enterprise AI Assistant - AWS Cloud Architecture"
SUBTITLE: "Designed by Ruben Martin | Date: July 3, 2025"

ARCHITECTURE OVERVIEW:
Design a multi-tier enterprise AI assistant that processes voice and text, analyzes documents (PDF, Word, Excel, images, videos), provides semantic search with vector embeddings, includes role-based access control, and generates documents.

MAIN COMPONENTS TO INCLUDE:

LAYER 1 - USER ACCESS & EDGE:
- External users group
- Corporate network
- AWS Route 53 DNS
- AWS WAF (Web Application Firewall)
- Amazon CloudFront CDN
- SSL certificate symbol

LAYER 2 - FRONTEND:
- Amazon S3 bucket for static website
- CloudFront distribution
- Custom domain: ai-assistant.company.com
- Web application interface

LAYER 3 - API & AUTHENTICATION:
- Amazon API Gateway REST endpoints
- Amazon Cognito User Pool
- JWT token validation
- Rate limiting controls

LAYER 4 - NETWORKING:
- Amazon VPC: 10.1.0.0/16
- Three Availability Zones: us-east-1a, us-east-1b, us-east-1c
- Public subnets: 10.1.1.0/24, 10.1.2.0/24, 10.1.3.0/24
- Private subnets: 10.1.10.0/24, 10.1.20.0/24, 10.1.30.0/24
- Internet Gateway
- NAT Gateways (one per AZ)
- Application Load Balancer
- VPC Endpoints for S3 and Secrets Manager

LAYER 5 - COMPUTE:
- Amazon ECS Fargate clusters across 3 AZs
- AWS Lambda functions:
  * Document processor
  * Text analyzer
  * Voice processor
  * Response generator
- Auto Scaling Groups

LAYER 6 - AI SERVICES:
- Amazon Bedrock with models:
  * Anthropic Claude 3 Sonnet
  * Anthropic Claude 3 Haiku
  * Cohere Embed English v3
  * Amazon Titan Embed Text v1
- Amazon OpenSearch Service: 3 nodes, t3.medium.search
- Amazon Transcribe (speech-to-text)
- Amazon Polly (text-to-speech)
- Amazon Textract (document extraction)
- Amazon Rekognition (image/video analysis)

LAYER 7 - DATA STORAGE:
- Amazon Aurora MySQL Serverless v2:
  * 2 instances across AZs
  * Auto-scaling: 2-16 ACUs
- Amazon S3 Data Lake with buckets:
  * Raw Documents
  * Processed Documents
  * Embeddings
  * User Uploads
  * Generated Documents
  * Backup
- Amazon ElastiCache Redis cluster

LAYER 8 - SECURITY:
- AWS KMS for encryption
- AWS Secrets Manager
- AWS IAM roles and policies
- Security Groups
- AWS CloudTrail audit logging

LAYER 9 - MONITORING:
- Amazon CloudWatch Logs
- Amazon CloudWatch Metrics
- AWS X-Ray tracing
- Aurora Performance Insights

DATA FLOW CONNECTIONS:

PRIMARY FLOWS:
1. User Request: Users → Route 53 → CloudFront → WAF → ALB → API Gateway → Lambda → Aurora/OpenSearch
2. Document Upload: User → API Gateway → Lambda → S3 Raw → Textract → S3 Processed → OpenSearch
3. Voice Processing: User → API Gateway → Lambda → Transcribe → Bedrock → Polly → Response
4. Search Query: Query → Lambda → Bedrock Embeddings → OpenSearch → Results

TECHNICAL SPECIFICATIONS:
- Aurora MySQL Serverless v2: 2-16 ACUs, 99.99% SLA
- OpenSearch: 3 nodes, t3.medium.search, 100GB storage each
- Lambda: Auto-scaling, 15-minute timeout
- ECS Fargate: Auto-scaling, 4 vCPU, 8GB RAM per task
- API Gateway: <500ms p95 latency
- Vector search: <100ms response time

LAYOUT REQUIREMENTS:
- Arrange components in logical layers from top to bottom
- Show data flow with labeled arrows
- Group related services in containers
- Use standard AWS architecture diagram style
- Include all service names and key specifications

VISUAL ELEMENTS:
- Use official AWS service icons
- Show high availability with multi-AZ indicators
- Include encryption symbols on data stores
- Add auto-scaling arrows where applicable
- Show bidirectional data flows where needed

ANNOTATIONS TO INCLUDE:
- Network CIDR blocks on subnets
- Capacity specifications on services
- Security features (encryption, WAF protection)
- Performance metrics (latency, throughput)
- Cost optimization features (serverless, intelligent tiering)

Create a professional, enterprise-ready architecture diagram suitable for technical and executive audiences.
```

---

## 🎨 MANUAL COLOR CODING GUIDE

Since Lucid AI doesn't automatically assign colors, here's the manual color scheme to apply after generation:

### 📋 LAYER COLOR ASSIGNMENTS:

**LAYER 1 - User Access & Edge:** Light Blue (#E3F2FD)
- Route 53, CloudFront, WAF, Users

**LAYER 2 - Frontend:** Light Orange (#FFF3E0)
- S3 static website, CloudFront distribution

**LAYER 3 - API & Auth:** Light Green (#E8F5E8)
- API Gateway, Cognito User Pool

**LAYER 4 - Networking:** Light Gray (#F5F5F5)
- VPC, Subnets, Load Balancers, NAT Gateways

**LAYER 5 - Compute:** Light Green (#E8F5E8)
- ECS Fargate, Lambda functions, Auto Scaling

**LAYER 6 - AI Services:** Light Purple (#F3E5F5)
- Bedrock, OpenSearch, Transcribe, Polly, Textract, Rekognition

**LAYER 7 - Data Storage:** Light Blue (#E1F5FE)
- Aurora MySQL, S3 buckets, ElastiCache

**LAYER 8 - Security:** Light Red (#FFEBEE)
- KMS, Secrets Manager, IAM, Security Groups, CloudTrail

**LAYER 9 - Monitoring:** Light Yellow (#FFFDE7)
- CloudWatch components, X-Ray, Performance Insights

---

## 🛠️ STEP-BY-STEP LUCID WORKFLOW

### Step 1: Generate Base Diagram
1. Copy the optimized prompt above
2. Paste into Lucid AI
3. Generate the initial architecture

### Step 2: Apply Manual Formatting
1. Select components by layer
2. Use top toolbar to apply colors per the guide above
3. Adjust sizing for hierarchy (larger for main services)

### Step 3: Add Conditional Formatting (Optional)
1. Open Conditional Formatting tab
2. Create rules for:
   - High Availability services (green border)
   - Encrypted services (lock icon)
   - Auto-scaling services (scaling arrows)

### Step 4: Final Adjustments
1. Align components within layers
2. Adjust arrow styles (solid for sync, dashed for async)
3. Add legend with color explanations
4. Include header with title and your name

---

## 🎯 ALTERNATIVE SIMPLIFIED PROMPTS

If the main prompt is too complex, try these shorter versions:

### BASIC VERSION:
```
Create an AWS architecture diagram for an AI Assistant with:
- Frontend: CloudFront, S3, API Gateway, Cognito
- Compute: Lambda, ECS Fargate
- AI: Bedrock, OpenSearch, Transcribe, Polly
- Data: Aurora MySQL, S3 Data Lake
- Security: WAF, KMS, IAM
Show connections between components with arrows.
Title: "Enterprise AI Assistant - AWS Architecture"
Author: "Ruben Martin | July 3, 2025"
```

### FOCUSED VERSION:
```
Design AWS AI Assistant architecture showing:
1. Users connecting through CloudFront to S3 frontend
2. API Gateway with Cognito authentication
3. Lambda functions processing requests
4. Bedrock AI models and OpenSearch for search
5. Aurora database and S3 data lake
6. Include VPC with public/private subnets
Label all components and show data flow arrows.
```

---

## 📊 TROUBLESHOOTING TIPS

### If Lucid AI struggles with complexity:
1. **Start with basic version** and add components incrementally
2. **Generate in sections** (networking first, then services)
3. **Use simpler language** and fewer technical specifications

### If layout isn't optimal:
1. **Ask for horizontal layout**: "Arrange components left to right"
2. **Request grouping**: "Group related services in containers"
3. **Specify flow direction**: "Show data flow from left (users) to right (data)"

### If icons are wrong:
1. **Specify AWS official icons**: "Use official AWS service icons"
2. **Request recent versions**: "Use latest AWS icon set"
3. **Name services explicitly**: "Amazon S3, not just S3"

---

## ✅ SUCCESS CHECKLIST

After generation, verify the diagram includes:

- [ ] All 9 layers with proper components
- [ ] Correct AWS service names and icons
- [ ] Data flow arrows with labels
- [ ] Network specifications (VPC, subnets)
- [ ] Title with your name and date
- [ ] Technical annotations (capacities, specifications)
- [ ] Professional layout suitable for presentations

---

**Optimized prompt designed to work within Lucid AI's current capabilities while maintaining technical accuracy and professional appearance.**