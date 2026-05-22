# 🏪 Proyecto Tienda - Estructura Docker y CI/CD

Documentación completa de la infraestructura Docker, CI/CD con GitHub Actions y despliegue en AWS EC2.

## 📑 Tabla de Contenidos

1. [Estructura del Proyecto](#estructura-del-proyecto)
2. [Archivos Generados](#archivos-generados)
3. [Requisitos Previos](#requisitos-previos)
4. [Configuración Local](#configuración-local)
5. [Configuración GitHub Secrets](#configuración-github-secrets)
6. [Despliegue en AWS EC2](#despliegue-en-aws-ec2)
7. [Flujo CI/CD](#flujo-cicd)
8. [Troubleshooting](#troubleshooting)

---

## 🏗️ Estructura del Proyecto

```
repo-tienda-eva2/
├── front_despacho/                    # Frontend React + Vite
│   ├── Dockerfile                     # Multi-stage build Node + Nginx
│   ├── nginx.conf                     # Configuración Nginx optimizada
│   ├── .dockerignore                  # Archivos excluidos en build
│   ├── src/
│   ├── package.json
│   └── vite.config.js
│
├── back-Ventas_SpringBoot/
│   └── Springboot-API-REST/           # Microservicio Ventas
│       ├── Dockerfile                 # Multi-stage build Maven + JDK21
│       ├── .dockerignore
│       ├── pom.xml
│       ├── mvnw
│       └── src/
│
├── back-Despachos_SpringBoot/
│   └── Springboot-API-REST-DESPACHO/  # Microservicio Despachos
│       ├── Dockerfile                 # Multi-stage build Maven + JDK21
│       ├── .dockerignore
│       ├── pom.xml
│       ├── mvnw
│       └── src/
│
├── .github/
│   └── workflows/                     # GitHub Actions
│       ├── frontend.yml               # Workflow para frontend
│       ├── ventas.yml                 # Workflow para backend ventas
│       └── despachos.yml              # Workflow para backend despachos
│
├── docker-compose.yml                 # Orquestación local
├── .env.example                       # Variables de entorno ejemplo
├── install-docker-ec2.sh              # Script instalación Docker en EC2
├── configure-aws-sg.sh                # Script configuración AWS Security Group
├── DOCKER_CICD_GUIDE.md               # Documentación detallada
└── README.md                          # Este archivo
```

---

## 📦 Archivos Generados

### 1. **Dockerfiles** (3 archivos)
- `front_despacho/Dockerfile` - Frontend React/Vite
- `back-Ventas_SpringBoot/Springboot-API-REST/Dockerfile` - Backend Ventas
- `back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO/Dockerfile` - Backend Despachos

**Características:**
- ✅ Multi-stage builds (reducen tamaño ~70%)
- ✅ Imágenes base optimizadas (alpine)
- ✅ Health checks integrados
- ✅ Variables de entorno configurables
- ✅ Security best practices

### 2. **Configuración de Nginx**
- `front_despacho/nginx.conf` - Proxy reverso y SPA routing

**Características:**
- ✅ SPA routing correcto (`try_files`)
- ✅ Compresión Gzip
- ✅ Cache control inteligente
- ✅ Headers de seguridad

### 3. **Docker Compose**
- `docker-compose.yml` - Orquestación de servicios

**Servicios:**
```
- frontend:80 (Nginx)
- backend-ventas:8080 (Spring Boot)
- backend-despachos:8081 (Spring Boot)
```

### 4. **GitHub Actions Workflows** (3 archivos)
- `.github/workflows/frontend.yml`
- `.github/workflows/ventas.yml`
- `.github/workflows/despachos.yml`

**Características:**
- ✅ Trigger en push a rama `deploy`
- ✅ Build multi-arquitectura
- ✅ Push a Docker Hub
- ✅ Escaneo de seguridad (Trivy)
- ✅ Caching de capas

### 5. **Scripts de Automatización**
- `install-docker-ec2.sh` - Instala Docker en EC2
- `configure-aws-sg.sh` - Configura Security Groups

### 6. **Documentación**
- `DOCKER_CICD_GUIDE.md` - Guía detallada de Docker y CI/CD
- `.env.example` - Ejemplo de variables de entorno

---

## 📋 Requisitos Previos

### Local (para testing)
- Docker Desktop (Windows/Mac) o Docker Engine (Linux)
- Docker Compose
- Git

### GitHub
- Repositorio con permisos de Actions
- Docker Hub account

### AWS
- Cuenta AWS activa
- EC2 instance (Ubuntu 22.04+ recomendado)
- Security Group configurado
- Key pair para SSH

---

## 🖥️ Configuración Local

### 1. Clonar Repositorio

```bash
git clone https://github.com/tu-usuario/repo-tienda-eva2.git
cd repo-tienda-eva2
git checkout deploy
```

### 2. Crear archivo .env

```bash
# Copiar ejemplo
cp .env.example .env

# Editar variables si es necesario
nano .env
```

### 3. Levantar Servicios con Docker Compose

```bash
# Build y run
docker compose up --build

# Background
docker compose up -d --build

# Ver logs
docker compose logs -f

# Logs específico
docker compose logs -f backend-ventas
```

### 4. Acceder a Servicios

```
- Frontend:           http://localhost
- Backend Ventas:     http://localhost:8080
- Backend Despachos:  http://localhost:8081
```

### 5. Detener Servicios

```bash
# Detener sin eliminar
docker compose stop

# Detener y eliminar
docker compose down

# Eliminar también volúmenes
docker compose down -v
```

---

## 🔐 Configuración GitHub Secrets

Necesarios para que los workflows funcionen.

### Pasos:

1. **Ir a Settings del Repositorio**
   ```
   https://github.com/tu-usuario/repo-tienda-eva2/settings/secrets/actions
   ```

2. **Crear Secrets**

   - **DOCKER_USERNAME**
     ```
     Tu usuario de Docker Hub
     Ej: tu_usuario_docker
     ```

   - **DOCKER_PASSWORD**
     ```
     Token de acceso de Docker Hub (no contraseña)
     Generar en: https://hub.docker.com/settings/security
     ```

3. **Verificar Secrets**
   ```
   Settings > Secrets and variables > Actions
   ```

### Generar Docker Token

1. Ir a https://hub.docker.com/settings/security
2. Click en "New Access Token"
3. Nombre: `github-actions`
4. Permisos: Read, Write, Delete
5. Copiar token y agregarlo a GitHub Secrets

---

## 🚀 Despliegue en AWS EC2

### Paso 1: Lanzar EC2 Instance

1. AWS Console > EC2 > Launch Instance
2. Seleccionar: **Ubuntu 22.04 LTS**
3. Instance Type: `t3.medium` (recomendado para 3 contenedores)
4. Security Group: Crear nuevo
5. Launch

### Paso 2: Conectar a EC2

```bash
# Cambiar permisos de key (solo 1ª vez)
chmod 600 tu-key.pem

# Conectar por SSH
ssh -i tu-key.pem ubuntu@ec2-tu-ip.compute-1.amazonaws.com
```

### Paso 3: Instalar Docker

**Opción A: Script Automático**

```bash
# Descargar script
wget https://raw.githubusercontent.com/tu-usuario/repo-tienda-eva2/deploy/install-docker-ec2.sh

# Ejecutar con permisos
chmod +x install-docker-ec2.sh
sudo ./install-docker-ec2.sh
```

**Opción B: Manual**

```bash
sudo apt-get update && sudo apt-get upgrade -y

# Instalar Docker
sudo apt-get install -y docker.io docker-compose-plugin

# Agregar usuario al grupo docker
sudo usermod -aG docker ubuntu
newgrp docker
```

### Paso 4: Clonar Repositorio

```bash
# Clonar
git clone https://github.com/tu-usuario/repo-tienda-eva2.git
cd repo-tienda-eva2

# Cambiar a rama deploy
git checkout deploy

# Crear .env si es necesario
cp .env.example .env
```

### Paso 5: Levantar Servicios

```bash
# Pull imagenes del registry (si ya fueron pusheadas)
docker compose pull

# Build y run
docker compose up -d --build

# Verificar estado
docker compose ps

# Ver logs
docker compose logs -f
```

### Paso 6: Configurar Security Group

```bash
# Obtener el ID del security group
aws ec2 describe-security-groups --filters Name=group-name,Values=launch-wizard-* --query 'SecurityGroups[0].GroupId'

# Ejecutar script de configuración
chmod +x configure-aws-sg.sh
./configure-aws-sg.sh sg-0123456789abcdef0
```

O manualmente en AWS Console:

**Inbound Rules:**
| Protocol | Port  | Source       | Descripción           |
|----------|-------|------------- |----------------------|
| TCP      | 22    | 0.0.0.0/0    | SSH Access            |
| TCP      | 80    | 0.0.0.0/0    | Frontend HTTP         |
| TCP      | 443   | 0.0.0.0/0    | Frontend HTTPS        |
| TCP      | 8080  | 0.0.0.0/0    | Backend Ventas        |
| TCP      | 8081  | 0.0.0.0/0    | Backend Despachos     |

### Paso 7: Acceder a Aplicación

```
Frontend:           http://ec2-ip:80
Backend Ventas:     http://ec2-ip:8080
Backend Despachos:  http://ec2-ip:8081
```

---

## 🔄 Flujo CI/CD Completo

```
┌─────────────────────────────────────────────────┐
│  Developer hace push en rama 'deploy'           │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  GitHub Actions dispara 3 workflows en paralelo │
│  - frontend.yml                                 │
│  - ventas.yml                                   │
│  - despachos.yml                                │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  Checkout código + Setup Docker Buildx          │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  Login a Docker Hub                             │
│  (usando DOCKER_USERNAME y DOCKER_PASSWORD)     │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  Build Docker image                             │
│  - Multi-stage build                            │
│  - Cache de capas anteriores                    │
│  - Tags: latest + SHA commit                    │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  Push a Docker Hub                              │
│  - tu-usuario-docker/tienda-frontend:latest     │
│  - tu-usuario-docker/tienda-backend-ventas:xyz  │
│  - tu-usuario-docker/tienda-backend-despachos:xyz
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  Scan de seguridad con Trivy                    │
│  - Detecta CVEs                                 │
│  - Upload a GitHub Security                     │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  ✅ Workflows completados                        │
│  Imágenes listas en Docker Hub                  │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  En EC2: docker compose pull                    │
│         docker compose up -d                    │
│         docker compose logs -f                  │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  ✅ Aplicación disponible en producción         │
│  Frontend: http://ec2-ip:80                     │
│  APIs: http://ec2-ip:8080, http://ec2-ip:8081  │
└─────────────────────────────────────────────────┘
```

---

## 📊 Comandos Útiles

### Docker Compose

```bash
# Iniciar servicios
docker compose up -d --build

# Detener servicios
docker compose down

# Ver estado
docker compose ps

# Logs en tiempo real
docker compose logs -f

# Logs de un servicio
docker compose logs -f backend-ventas

# Reconstruir una imagen
docker compose build --no-cache frontend

# Ejecutar comando en contenedor
docker compose exec backend-ventas sh

# Reinicar servicio
docker compose restart frontend
```

### Docker

```bash
# Listar imágenes
docker images

# Listar contenedores
docker ps -a

# Ver logs
docker logs -f container-name

# Eliminar imagen
docker rmi imagen:tag

# Eliminar contenedor
docker rm container-name

# Eliminar no usados
docker system prune
```

### Git (CI/CD)

```bash
# Cambiar a rama deploy
git checkout deploy

# Hacer cambios y commit
git add .
git commit -m "Update backend ventas"

# Push (dispara workflows)
git push origin deploy

# Ver workflows en GitHub Actions
# https://github.com/tu-usuario/repo-tienda-eva2/actions
```

---

## 🐛 Troubleshooting

### Frontend no muestra contenido

```bash
# Verificar logs de Nginx
docker compose logs frontend

# Acceder al contenedor
docker compose exec frontend sh

# Verificar que Nginx está corriendo
docker compose exec frontend nginx -t

# Ver archivos servidos
docker compose exec frontend ls /usr/share/nginx/html
```

### Backend no responde

```bash
# Logs de la app
docker compose logs backend-ventas

# Health check
docker compose exec backend-ventas wget -O - http://localhost:8080/actuator/health

# Conectarse a contenedor
docker compose exec backend-ventas bash
```

### Error de puerto en uso

```bash
# Encontrar proceso usando puerto 8080
lsof -i :8080

# Matar proceso
kill -9 PID

# O cambiar puerto en docker-compose.yml:
# "8080:8080" → "8082:8080"
```

### GitHub Actions no ejecuta

1. Verificar rama es `deploy`
2. Verificar `DOCKER_USERNAME` y `DOCKER_PASSWORD` en Secrets
3. Verificar permisos de Actions en repository settings
4. Ver logs en: GitHub > Actions > último workflow

### Permisos en EC2

```bash
# Si no puedes ejecutar docker sin sudo
sudo usermod -aG docker ubuntu
newgrp docker

# Verificar
docker ps
```

### EC2 no puede alcanzar Docker Hub

```bash
# Verificar conexión
ping docker.io

# Si hay firewall, permitir en Security Group
# Outbound: TCP 443 a 0.0.0.0/0
```

---

## 📋 Checklist de Despliegue

### Pre-despliegue Local
- [ ] Docker Desktop instalado y corriendo
- [ ] `docker compose up --build` funciona localmente
- [ ] Todos los servicios responden en `localhost`
- [ ] Logs sin errores críticos

### Pre-despliegue GitHub
- [ ] Rama `deploy` existe
- [ ] `DOCKER_USERNAME` en GitHub Secrets
- [ ] `DOCKER_PASSWORD` en GitHub Secrets
- [ ] Docker Hub username correcto en workflows
- [ ] Actions habilitadas en Settings

### Pre-despliegue AWS
- [ ] EC2 instance creada y corriendo
- [ ] SSH funciona (key pair correcto)
- [ ] Security Group permite puertos 22, 80, 8080, 8081
- [ ] Ubuntu 22.04+ instalado
- [ ] Docker instalado en EC2

### Post-despliegue
- [ ] `docker compose ps` muestra 3 containers corriendo
- [ ] Frontend accesible en `http://ec2-ip`
- [ ] APIs responden en puertos correctos
- [ ] Health checks pasan
- [ ] Logs sin errores

---

## 🔒 Seguridad

### Best Practices Implementadas

✅ **Images:**
- Imágenes base oficiales
- No corren como root
- Multi-stage builds

✅ **Registry:**
- Docker Hub con permisos limitados
- Token en lugar de contraseña
- Secrets en GitHub (no hardcoded)

✅ **Network:**
- Network bridge interno
- Puertos expuestos mínimos
- Security Groups restrictivos

✅ **Scanning:**
- Trivy scans en cada build
- CVE reporting automático

### Mejorar Seguridad

```bash
# Usar Private Container Registry
# - AWS ECR en lugar de Docker Hub
# - Configurar IAM roles

# HTTPS en Nginx
# - Generar certificado SSL/TLS
# - Redirect HTTP a HTTPS

# Environment secrets
# - No hardcodear en Dockerfile
# - Usar .env files
# - AWS Secrets Manager

# Database
# - Agregarbase de datos en docker-compose
# - Usar credenciales seguros
# - Backups automáticos
```

---

## 📚 Recursos

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Spring Boot Production-ready Features](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)

---

## 👨‍💼 Soporte

Para preguntas o problemas:

1. Revisar [DOCKER_CICD_GUIDE.md](./DOCKER_CICD_GUIDE.md)
2. Consultar [Troubleshooting](#troubleshooting)
3. Revisar logs: `docker compose logs`
4. GitHub Issues en el repositorio

---

**Generado para evaluación DevOps universitaria** ✨

Última actualización: 2026-05-22
