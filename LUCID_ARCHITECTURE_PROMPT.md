# Prompt para Lucid AI - Arquitectura del Asistente IA Empresarial

**Autor:** Ruben Martin  
**Fecha:** 2025-07-03  
**Proyecto:** AI Assistant Infrastructure

---

## 🎨 PROMPT PARA LUCID AI

```
Create a comprehensive AWS cloud architecture diagram for an Enterprise AI Assistant infrastructure with the following specifications:

TITLE: "Enterprise AI Assistant - AWS Cloud Architecture"
SUBTITLE: "Designed by Ruben Martin | Date: July 3, 2025"

MAIN COMPONENTS TO INCLUDE:

1. USERS AND ACCESS LAYER:
   - External users icon (multiple people)
   - Corporate network cloud
   - Internet gateway symbol
   - AWS WAF shield icon
   - Route 53 DNS service
   - CloudFront CDN distribution

2. FRONTEND LAYER:
   - S3 bucket for static website hosting
   - CloudFront distribution connected to S3
   - Custom domain: "ai-assistant.company.com"
   - HTTPS certificate symbol

3. API AND AUTHENTICATION LAYER:
   - Amazon API Gateway (REST API)
   - Amazon Cognito User Pool
   - AWS Lambda functions (multiple)
   - Connection between Cognito and API Gateway

4. NETWORKING INFRASTRUCTURE:
   - VPC with CIDR 10.1.0.0/16
   - 3 Availability Zones (us-east-1a, us-east-1b, us-east-1c)
   - Public subnets: 10.1.1.0/24, 10.1.2.0/24, 10.1.3.0/24
   - Private subnets: 10.1.10.0/24, 10.1.20.0/24, 10.1.30.0/24
   - Internet Gateway
   - NAT Gateways (3, one per AZ)
   - Application Load Balancer in public subnets

5. COMPUTE LAYER:
   - ECS Fargate clusters in private subnets
   - AWS Lambda functions for document processing
   - Auto Scaling Groups
   - ECS tasks for AI processing

6. AI SERVICES LAYER:
   - Amazon Bedrock (Claude models)
   - Amazon OpenSearch Service cluster (3 nodes)
   - Amazon Transcribe service
   - Amazon Polly service
   - Amazon Textract service
   - Amazon Rekognition service

7. DATA LAYER:
   - Aurora MySQL Serverless v2 cluster (2 instances)
   - S3 Data Lake with multiple buckets:
     * Raw Documents
     * Processed Documents
     * Embeddings
     * User Uploads
     * Generated Documents
     * Backup
   - ElastiCache Redis cluster

8. SECURITY COMPONENTS:
   - AWS KMS for encryption
   - AWS Secrets Manager
   - IAM roles and policies
   - Security Groups (showing firewall rules)
   - VPC Endpoints for S3 and Secrets Manager

9. MONITORING AND LOGGING:
   - CloudWatch Logs
   - CloudWatch Metrics
   - AWS X-Ray tracing
   - Performance Insights for Aurora

VISUAL REQUIREMENTS:

- Use AWS official icons and colors
- Show data flow arrows between components
- Use different colors for different layers:
  * Blue for networking
  * Orange for compute
  * Green for data storage
  * Purple for AI services
  * Red for security
  * Yellow for monitoring

- Include security zones:
  * Public subnet zone (light blue background)
  * Private subnet zone (light gray background)
  * Database subnet zone (light green background)

- Show the following connections:
  * Users → CloudFront → S3
  * Users → WAF → ALB → API Gateway
  * API Gateway → Lambda → OpenSearch
  * Lambda → Aurora Database
  * Lambda → S3 Data Lake
  * ECS → Bedrock AI services
  * All components → CloudWatch

TECHNICAL ANNOTATIONS:
- Add capacity specifications: "Aurora: 2-16 ACUs", "OpenSearch: 3 nodes", "Lambda: Auto-scaling"
- Include network CIDR blocks on subnets
- Show encryption symbols on data stores
- Add high availability indicators (multi-AZ)
- Include cost optimization notes: "Lifecycle policies", "Serverless scaling"

LAYOUT STYLE:
- Horizontal flow from left (users) to right (data)
- Group related services in logical containers
- Use clean, professional AWS architecture diagram style
- Include legend for icons and color coding
- Add creation date and author information in footer

Make sure all components are properly connected with labeled arrows showing data flow, and include proper AWS service names and terminology.
```

---

## 🎯 COMPONENTES ESPECÍFICOS PARA VERIFICAR

### Servicios AWS a Incluir:
✅ **Compute**: ECS Fargate, Lambda, Auto Scaling  
✅ **Storage**: S3, Aurora MySQL Serverless v2, ElastiCache  
✅ **AI/ML**: Bedrock, OpenSearch, Transcribe, Polly, Textract, Rekognition  
✅ **Security**: Cognito, IAM, KMS, Secrets Manager, WAF  
✅ **Networking**: VPC, Subnets, ALB, API Gateway, CloudFront, Route 53  
✅ **Monitoring**: CloudWatch, X-Ray, Performance Insights  

### Conexiones Críticas:
✅ **Users → CloudFront → S3** (Frontend)  
✅ **Users → WAF → ALB → API Gateway** (API)  
✅ **API Gateway → Lambda → OpenSearch** (AI Processing)  
✅ **Lambda → Aurora** (Database Access)  
✅ **Lambda → S3 Data Lake** (Document Storage)  
✅ **ECS → Bedrock** (AI Models)  

### Especificaciones Técnicas:
✅ **VPC CIDR**: 10.1.0.0/16  
✅ **AZs**: us-east-1a, us-east-1b, us-east-1c  
✅ **Aurora**: 2-16 ACUs, Serverless v2  
✅ **OpenSearch**: 3 nodos, t3.medium.search  
✅ **Dominio**: ai-assistant.company.com  

---

## 📋 CHECKLIST PARA LUCID AI

Antes de generar, verificar que incluya:

- [ ] Título con autor y fecha
- [ ] Todos los 9 componentes principales
- [ ] Colores por capas según especificación
- [ ] Iconos oficiales de AWS
- [ ] Flechas de flujo de datos etiquetadas
- [ ] CIDRs de red en subredes
- [ ] Especificaciones de capacidad
- [ ] Zonas de seguridad con fondos de color
- [ ] Leyenda de iconos y colores
- [ ] Footer con información de creación

---

## 🎨 PERSONALIZACIÓN ADICIONAL

Si necesitas ajustar el diagrama después de la generación inicial:

### Para agregar más detalle:
"Add detailed security group rules between components"
"Include specific port numbers on connections"
"Show backup and disaster recovery flows"

### Para simplificar:
"Create a high-level overview version"
"Focus only on main data flows"
"Remove technical specifications for executive presentation"

### Para diferentes audiencias:
"Create technical version with all specifications"
"Create business version focusing on capabilities"
"Create security-focused version highlighting compliance"

---

**Prompt optimizado para generar la arquitectura completa del Asistente IA Empresarial**