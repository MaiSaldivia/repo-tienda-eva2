#!/bin/bash
# ============================================
# CONFIGURACIÓN DE AWS SECURITY GROUP
# ============================================
# Este script configura los security groups necesarios en AWS para el proyecto
# Uso: ./configure-aws-sg.sh <security-group-id>

if [ -z "$1" ]; then
    echo "Uso: $0 <security-group-id>"
    echo "Ejemplo: $0 sg-0123456789abcdef0"
    exit 1
fi

SG_ID=$1
REGION=${2:-us-east-1}

echo "Configurando Security Group: $SG_ID en región: $REGION"

# Función para agregar regla
add_rule() {
    local port=$1
    local protocol=$2
    local description=$3
    
    echo "Agregando regla: Puerto $port ($protocol) - $description"
    
    aws ec2 authorize-security-group-ingress \
        --group-id "$SG_ID" \
        --protocol "$protocol" \
        --port "$port" \
        --cidr 0.0.0.0/0 \
        --region "$REGION" \
        --tag-specifications "ResourceType=security-group-rule,Tags=[{Key=Name,Value=$description}]" 2>/dev/null || \
    echo "  ⚠️  Regla ya existe o error (ignorando)"
}

echo "============================================"
echo "Configurando puertos necesarios..."
echo "============================================"

# Puerto SSH
add_rule 22 tcp "SSH Access"

# Puerto Frontend (Nginx)
add_rule 80 tcp "Frontend HTTP"

# Puerto HTTPS (si aplica)
add_rule 443 tcp "Frontend HTTPS"

# Puerto Backend Ventas
add_rule 8080 tcp "Backend Ventas API"

# Puerto Backend Despachos
add_rule 8081 tcp "Backend Despachos API"

echo ""
echo "✅ Security Group configurado correctamente"
echo ""
echo "Verificar reglas:"
echo "aws ec2 describe-security-groups --group-ids $SG_ID --region $REGION"
