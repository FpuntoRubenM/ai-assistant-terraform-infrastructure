# Guía de Despliegue - AI Assistant Infrastructure

**Autor:** Ruben Martin  
**Fecha:** 2025-07-03

## 🚀 Guía de Despliegue Paso a Paso

### 1. Prerrequisitos

#### Herramientas Requeridas
```bash
# Terraform >= 1.5
terraform --version

# AWS CLI configurado
aws configure list

# Git para control de versiones
git --version
```

#### Recursos AWS Preexistentes
Antes del despliegue, crear manualmente:

```bash
# 1. Bucket S3 para estado de Terraform
aws s3 mb s3://mi-terraform-state-bucket --region us-east-1

# 2. Tabla DynamoDB para bloqueo de estado
aws dynamodb create-table \
  --table-name mi-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### 2. Configuración Inicial

#### Clonar y Configurar Repositorio
```bash
# Clonar repositorio
git clone <repository-url>
cd ai-assistant-terraform

# Configurar backend de Terraform
cp backend.hcl backend-prod.hcl
# Editar backend-prod.hcl con tus valores

# Configurar variables de entorno
export TF_VAR_owner="Tu Nombre o Equipo"
```

#### Editar Variables de Entorno
```bash
# Desarrollo
cp environments/dev.tfvars environments/mi-dev.tfvars
vim environments/mi-dev.tfvars

# Producción  
cp environments/prod.tfvars environments/mi-prod.tfvars
vim environments/mi-prod.tfvars
```

### 3. Despliegue por Entornos

#### Entorno de Desarrollo

```bash
# 1. Inicializar Terraform
terraform init -backend-config=backend-dev.hcl

# 2. Planificar cambios
terraform plan -var-file="environments/mi-dev.tfvars" -out=dev.tfplan

# 3. Revisar plan
terraform show dev.tfplan

# 4. Aplicar cambios
terraform apply dev.tfplan

# 5. Verificar outputs
terraform output
```

#### Entorno de Producción

```bash
# 1. Cambiar workspace (opcional)
terraform workspace new prod
terraform workspace select prod

# 2. Inicializar con backend de producción
terraform init -backend-config=backend-prod.hcl

# 3. Planificar cambios (revisión exhaustiva)
terraform plan -var-file="environments/mi-prod.tfvars" -out=prod.tfplan

# 4. Revisar plan detalladamente
terraform show prod.tfplan | less

# 5. Aplicar con confirmación manual
terraform apply prod.tfplan
```

### 4. Verificación Post-Despliegue

#### Verificar Servicios Críticos

```bash
# 1. Verificar VPC y subredes
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=ai-assistant"

# 2. Verificar Aurora cluster
aws rds describe-db-clusters --db-cluster-identifier ai-assistant-prod-aurora-cluster

# 3. Verificar OpenSearch domain
aws opensearch describe-domain --domain-name ai-assistant-prod-vector-store

# 4. Verificar buckets S3
aws s3 ls | grep ai-assistant-prod

# 5. Verificar Cognito User Pool
aws cognito-idp list-user-pools --max-items 10
```

#### Pruebas de Conectividad

```bash
# 1. Probar conexión a OpenSearch
terraform output opensearch_endpoint
curl -k "https://$(terraform output -raw opensearch_endpoint)/_cluster/health"

# 2. Verificar dominio de Cognito
terraform output cognito_user_pool_domain
curl "https://$(terraform output -raw cognito_user_pool_domain).auth.us-east-1.amazoncognito.com/.well-known/openid_configuration"
```

### 5. Configuración Post-Despliegue

#### Configurar DNS (si usas dominio personalizado)

```bash
# Obtener información de CloudFront
terraform output deployment_info

# Crear registro CNAME en tu DNS
# Ejemplo para Route53:
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://dns-change.json
```

#### Configurar Monitoreo

```bash
# 1. Crear dashboard de CloudWatch
aws cloudwatch put-dashboard \
  --dashboard-name "AI-Assistant-${ENVIRONMENT}" \
  --dashboard-body file://monitoring/dashboard.json

# 2. Configurar alarmas
aws cloudwatch put-metric-alarm \
  --alarm-name "AI-Assistant-HighLatency" \
  --alarm-description "API Gateway high latency" \
  --metric-name Latency \
  --namespace AWS/ApiGateway \
  --statistic Average \
  --period 300 \
  --threshold 5000 \
  --comparison-operator GreaterThanThreshold
```

### 6. Gestión de Usuarios

#### Crear Primer Usuario Admin

```bash
# 1. Obtener User Pool ID
USER_POOL_ID=$(terraform output -raw cognito_user_pool_id)

# 2. Crear usuario admin
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username admin@empresa.com \
  --user-attributes Name=email,Value=admin@empresa.com \
  --temporary-password TempPass123! \
  --message-action SUPPRESS

# 3. Asignar a grupo admin (crear grupo primero)
aws cognito-idp create-group \
  --group-name admin \
  --user-pool-id $USER_POOL_ID \
  --description "Administrators"

aws cognito-idp admin-add-user-to-group \
  --user-pool-id $USER_POOL_ID \
  --username admin@empresa.com \
  --group-name admin
```

### 7. Troubleshooting

#### Problemas Comunes

**Error: Backend already exists**
```bash
# Importar estado existente
terraform import aws_s3_bucket.terraform_state your-bucket-name

# O forzar inicialización
terraform init -reconfigure
```

**Error: Resource already exists**
```bash
# Importar recurso existente
terraform import aws_vpc.main vpc-12345678

# Ver estado actual
terraform state list
terraform state show aws_vpc.main
```

**Error: Insufficient permissions**
```bash
# Verificar políticas IAM
aws iam list-attached-user-policies --user-name tu-usuario
aws iam get-policy-version --policy-arn arn:aws:iam::aws:policy/PowerUserAccess --version-id v1
```

#### Logs y Debugging

```bash
# Habilitar logs detallados
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Revisar logs de AWS
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/ai-assistant"
aws logs get-log-events --log-group-name "/aws/lambda/ai-assistant-prod-processor"
```

### 8. Actualización y Mantenimiento

#### Actualizar Infraestructura

```bash
# 1. Backup del estado actual
aws s3 cp s3://mi-terraform-state-bucket/ai-assistant/terraform.tfstate ./backup/

# 2. Actualizar código
git pull origin main

# 3. Planificar cambios
terraform plan -var-file="environments/prod.tfvars"

# 4. Aplicar incrementalmente
terraform apply -target=module.networking
terraform apply -target=module.storage
# ... continuar por módulos
```

#### Backup y Recuperación

```bash
# Backup automático con script
#!/bin/bash
DATE=$(date +%Y%m%d-%H%M%S)
aws s3 cp s3://mi-terraform-state-bucket/ai-assistant/terraform.tfstate \
  s3://mi-backups-bucket/terraform-state/terraform.tfstate.$DATE

# Recuperación desde backup
aws s3 cp s3://mi-backups-bucket/terraform-state/terraform.tfstate.20250703-120000 \
  s3://mi-terraform-state-bucket/ai-assistant/terraform.tfstate
```

### 9. Destrucción (Solo Desarrollo)

**⚠️ ADVERTENCIA: Esto eliminará toda la infraestructura**

```bash
# Solo para entornos de desarrollo
terraform plan -destroy -var-file="environments/dev.tfvars"
terraform destroy -var-file="environments/dev.tfvars"

# Limpiar estado local
rm -rf .terraform/
rm terraform.tfstate*
```

### 10. Contacto y Soporte

- **Arquitecto**: Ruben Martin
- **Documentación**: Ver README.md
- **Issues**: Crear ticket en repositorio
- **Emergencias**: Contactar equipo DevOps

---

**© 2025 - Guía de despliegue por Ruben Martin**