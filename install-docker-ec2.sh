#!/bin/bash
set -e

echo "========================================="
echo "🚀 Instalación en AWS EC2 - Proyecto Tienda"
echo "========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar si es root
if [ "$EUID" -ne 0 ]; then 
   echo -e "${RED}Este script debe ejecutarse con sudo${NC}"
   exit 1
fi

echo -e "${YELLOW}[1/5] Actualizando paquetes del sistema...${NC}"
apt-get update
apt-get upgrade -y

echo -e "${YELLOW}[2/5] Instalando Docker...${NC}"
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo -e "${YELLOW}[3/5] Instalando Docker Compose (legacy)...${NC}"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo -e "${YELLOW}[4/5] Configurando permisos de usuario...${NC}"
# Obtener el usuario (asumiendo que es quien ejecuta con sudo)
SUDO_USER=${SUDO_USER:-ubuntu}
usermod -aG docker $SUDO_USER
newgrp docker

echo -e "${YELLOW}[5/5] Iniciando servicio Docker...${NC}"
systemctl enable docker
systemctl start docker

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Docker instalado correctamente!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Versiones instaladas:"
docker --version
docker-compose --version
echo ""
echo "Próximos pasos:"
echo "1. Clona el repositorio:"
echo "   git clone <tu-repo>"
echo "   cd repo-tienda-eva2"
echo "   git checkout deploy"
echo ""
echo "2. Levanta los servicios:"
echo "   docker compose up -d --build"
echo ""
echo "3. Verifica los logs:"
echo "   docker compose logs -f"
echo ""
