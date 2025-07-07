#!/bin/bash

# =============================================================================
# AI Assistant Infrastructure - GitHub Setup Script
# 
# Author: Ruben Martin
# Date: 2025-07-03
# Description: Script automatizado para configurar el repositorio de GitHub
#              y subir la infraestructura completa del asistente AI
# 
# Funcionalidades:
# - Inicialización del repositorio Git local
# - Configuración de .gitignore para archivos sensibles
# - Creación del repositorio remoto en GitHub
# - Push inicial con toda la infraestructura
# - Configuración de branch protection rules
# - Setup de GitHub Actions (opcional)
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración por defecto
REPO_NAME="ai-assistant-terraform-infrastructure"
DEFAULT_BRANCH="main"
GITHUB_USERNAME=""
REPO_DESCRIPTION="Enterprise AI Assistant Infrastructure with Terraform - Multi-cloud ready architecture"

# =============================================================================
# FUNCIONES AUXILIARES
# =============================================================================

print_header() {
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=================================================${NC}"
}

print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "El comando '$1' no está instalado. Por favor, instálalo antes de continuar."
        exit 1
    fi
}

# =============================================================================
# VALIDACIONES PREVIAS
# =============================================================================

print_header "VALIDANDO DEPENDENCIAS Y CONFIGURACIÓN"

# Verificar comandos necesarios
check_command "git"
check_command "gh"

# Verificar autenticación de GitHub CLI
if ! gh auth status &> /dev/null; then
    print_error "GitHub CLI no está autenticado. Ejecuta: gh auth login"
    exit 1
fi

print_step "GitHub CLI autenticado correctamente"

# Obtener información del usuario de GitHub
GITHUB_USERNAME=$(gh api user | jq -r '.login')
print_step "Usuario de GitHub detectado: $GITHUB_USERNAME"

# =============================================================================
# CONFIGURACIÓN INTERACTIVA
# =============================================================================

print_header "CONFIGURACIÓN DEL REPOSITORIO"

# Solicitar nombre del repositorio
read -p "Nombre del repositorio [$REPO_NAME]: " input_repo_name
REPO_NAME=${input_repo_name:-$REPO_NAME}

# Solicitar visibilidad del repositorio
echo "Selecciona la visibilidad del repositorio:"
echo "1) Privado (recomendado para infraestructura)"
echo "2) Público"
read -p "Opción [1]: " visibility_option
case $visibility_option in
    2) VISIBILITY="public" ;;
    *) VISIBILITY="private" ;;
esac

# Confirmar configuración
echo -e "\n${BLUE}Configuración del repositorio:${NC}"
echo "Nombre: $REPO_NAME"
echo "Visibilidad: $VISIBILITY"
echo "Usuario: $GITHUB_USERNAME"
echo "Descripción: $REPO_DESCRIPTION"

read -p "¿Proceder con esta configuración? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    print_warning "Configuración cancelada por el usuario"
    exit 0
fi

# =============================================================================
# INICIALIZACIÓN DEL REPOSITORIO LOCAL
# =============================================================================

print_header "INICIALIZANDO REPOSITORIO LOCAL"

# Verificar que estamos en el directorio correcto
if [[ ! -f "main.tf" ]]; then
    print_error "No se encontró main.tf. Asegúrate de ejecutar este script desde el directorio del proyecto."
    exit 1
fi

# Inicializar repositorio Git si no existe
if [[ ! -d ".git" ]]; then
    git init
    print_step "Repositorio Git inicializado"
else
    print_step "Repositorio Git ya existe"
fi

# Configurar rama principal
git checkout -b $DEFAULT_BRANCH 2>/dev/null || git checkout $DEFAULT_BRANCH
print_step "Rama principal configurada: $DEFAULT_BRANCH"

# =============================================================================
# CONFIGURACIÓN DE .GITIGNORE
# =============================================================================

print_header "CONFIGURANDO .GITIGNORE"

# Crear o actualizar .gitignore si no existe uno completo
if [[ ! -f ".gitignore" ]] || ! grep -q "terraform.tfstate" .gitignore; then
    cat > .gitignore << 'EOF'
# Terraform files
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Backend configuration (contains sensitive data)
backend.hcl

# Variable files that might contain secrets
*.auto.tfvars
secrets.tfvars

# OS and IDE files
.DS_Store
Thumbs.db
*.swp
*.swo
*~
.vscode/
.idea/

# Log files
*.log

# Backup files
*.backup
*.bak

# Temporary files
.tmp/
tmp/

# Environment files
.env
.env.local
.env.*.local

# AWS credentials (should never be committed)
.aws/
credentials

# Plan files
*.tfplan
plan.out
EOF
    print_step ".gitignore configurado correctamente"
else
    print_step ".gitignore ya existe y parece estar configurado"
fi

# =============================================================================
# PREPARACIÓN DE ARCHIVOS PARA COMMIT
# =============================================================================

print_header "PREPARANDO ARCHIVOS PARA COMMIT"

# Agregar todos los archivos excepto los ignorados
git add .

# Verificar que hay cambios para hacer commit
if git diff --staged --quiet; then
    print_warning "No hay cambios para hacer commit"
else
    print_step "Archivos preparados para commit"
fi

# =============================================================================
# CREACIÓN DEL REPOSITORIO EN GITHUB
# =============================================================================

print_header "CREANDO REPOSITORIO EN GITHUB"

# Verificar si el repositorio ya existe
if gh repo view "$GITHUB_USERNAME/$REPO_NAME" &> /dev/null; then
    print_warning "El repositorio $REPO_NAME ya existe en GitHub"
    read -p "¿Deseas continuar y hacer push a este repositorio existente? (y/N): " continue_existing
    if [[ ! $continue_existing =~ ^[Yy]$ ]]; then
        print_warning "Operación cancelada"
        exit 0
    fi
else
    # Crear repositorio en GitHub
    gh repo create "$REPO_NAME" \
        --description "$REPO_DESCRIPTION" \
        --$VISIBILITY \
        --source=. \
        --remote=origin \
        --push

    if [[ $? -eq 0 ]]; then
        print_step "Repositorio creado exitosamente en GitHub"
    else
        print_error "Error al crear el repositorio en GitHub"
        exit 1
    fi
fi

# =============================================================================
# COMMIT Y PUSH INICIAL
# =============================================================================

print_header "REALIZANDO COMMIT Y PUSH INICIAL"

# Hacer commit inicial si hay cambios
if ! git diff --staged --quiet; then
    git commit -m "feat: Initial infrastructure setup for AI Assistant

- Complete Terraform infrastructure for enterprise AI assistant
- Modular architecture with 7 specialized modules
- AWS services: Aurora Serverless v2, OpenSearch, Bedrock, S3, Cognito
- Security-first design with KMS encryption and IAM policies
- Multi-environment support (dev/prod)
- Comprehensive documentation and deployment guides

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    print_step "Commit inicial realizado"
fi

# Configurar remote origin si no existe
if ! git remote get-url origin &> /dev/null; then
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    print_step "Remote origin configurado"
fi

# Push al repositorio remoto
git push -u origin $DEFAULT_BRANCH

if [[ $? -eq 0 ]]; then
    print_step "Push inicial completado exitosamente"
else
    print_error "Error durante el push inicial"
    exit 1
fi

# =============================================================================
# CONFIGURACIÓN DE BRANCH PROTECTION (OPCIONAL)
# =============================================================================

print_header "CONFIGURACIÓN DE PROTECCIÓN DE RAMA"

read -p "¿Deseas configurar protección para la rama main? (Y/n): " setup_protection
if [[ $setup_protection =~ ^[Yy]$ ]] || [[ -z $setup_protection ]]; then
    # Configurar branch protection rules
    gh api repos/$GITHUB_USERNAME/$REPO_NAME/branches/$DEFAULT_BRANCH/protection \
        --method PUT \
        --field required_status_checks='{"strict":true,"contexts":[]}' \
        --field enforce_admins=true \
        --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
        --field restrictions=null \
        --field allow_force_pushes=false \
        --field allow_deletions=false \
        2>/dev/null

    if [[ $? -eq 0 ]]; then
        print_step "Protección de rama configurada"
    else
        print_warning "No se pudo configurar la protección de rama (puede requerir permisos de admin)"
    fi
fi

# =============================================================================
# CONFIGURACIÓN DE GITHUB ACTIONS (OPCIONAL)
# =============================================================================

print_header "CONFIGURACIÓN DE GITHUB ACTIONS"

read -p "¿Deseas crear un workflow básico de GitHub Actions para validación de Terraform? (Y/n): " setup_actions
if [[ $setup_actions =~ ^[Yy]$ ]] || [[ -z $setup_actions ]]; then
    
    # Crear directorio para workflows
    mkdir -p .github/workflows
    
    # Crear workflow de validación de Terraform
    cat > .github/workflows/terraform-validate.yml << 'EOF'
name: Terraform Validation

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ~1.5
    
    - name: Terraform Format Check
      run: terraform fmt -check -recursive
    
    - name: Terraform Init
      run: terraform init -backend=false
    
    - name: Terraform Validate
      run: terraform validate
    
    - name: Terraform Plan (Dry Run)
      run: terraform plan -input=false -var-file=environments/dev.tfvars
      env:
        TF_VAR_db_password: "dummy-password-for-validation"
EOF

    # Agregar y hacer commit del workflow
    git add .github/workflows/terraform-validate.yml
    git commit -m "ci: Add Terraform validation GitHub Actions workflow

- Validates Terraform syntax and formatting
- Runs on push to main/develop and PRs to main
- Includes format check, init, validate, and plan steps

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    git push origin $DEFAULT_BRANCH
    
    print_step "GitHub Actions workflow creado y subido"
fi

# =============================================================================
# CONFIGURACIÓN DE SECRETS (INFORMACIÓN)
# =============================================================================

print_header "CONFIGURACIÓN DE SECRETS DE GITHUB"

echo -e "${YELLOW}IMPORTANTE: Para usar este repositorio con GitHub Actions, necesitarás configurar los siguientes secrets:${NC}"
echo ""
echo "1. AWS_ACCESS_KEY_ID - Clave de acceso de AWS"
echo "2. AWS_SECRET_ACCESS_KEY - Clave secreta de AWS"
echo "3. TF_VAR_db_password - Contraseña para la base de datos Aurora"
echo ""
echo "Puedes configurar estos secrets en:"
echo "https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions"
echo ""

read -p "¿Deseas abrir la página de configuración de secrets ahora? (y/N): " open_secrets
if [[ $open_secrets =~ ^[Yy]$ ]]; then
    # Intentar abrir en el navegador
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions"
    elif command -v open &> /dev/null; then
        open "https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions"
    else
        echo "Por favor, abre manualmente: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions"
    fi
fi

# =============================================================================
# RESUMEN FINAL
# =============================================================================

print_header "CONFIGURACIÓN COMPLETADA EXITOSAMENTE"

echo -e "${GREEN}✅ Repositorio configurado correctamente:${NC}"
echo "   📁 Repositorio: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "   🔒 Visibilidad: $VISIBILITY"
echo "   🌟 Rama principal: $DEFAULT_BRANCH"
echo ""
echo -e "${BLUE}📋 Próximos pasos recomendados:${NC}"
echo "   1. Configurar secrets de AWS en GitHub"
echo "   2. Revisar y personalizar variables en environments/"
echo "   3. Ejecutar terraform plan localmente para validar"
echo "   4. Configurar backend remoto en backend.hcl"
echo "   5. Invitar colaboradores al repositorio si es necesario"
echo ""
echo -e "${BLUE}📚 Documentación disponible:${NC}"
echo "   - README.md: Arquitectura y configuración general"
echo "   - DEPLOY.md: Guía de despliegue paso a paso"
echo "   - LUCID_*.md: Prompts para diagramas de arquitectura"
echo ""
echo -e "${GREEN}🎉 ¡Tu infraestructura AI Assistant está lista para despegar!${NC}"