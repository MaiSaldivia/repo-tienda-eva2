# Guía de Dockerización y CI/CD - Proyecto Tienda

## 📋 Estructura de Archivos Creados

### 1. Dockerfiles
```
front_despacho/Dockerfile
back-Ventas_SpringBoot/Springboot-API-REST/Dockerfile
back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO/Dockerfile
```

### 2. Configuración de Nginx
```
front_despacho/nginx.conf
```

### 3. Orquestación de Contenedores
```
docker-compose.yml (en raíz del proyecto)
```

### 4. GitHub Actions Workflows
```
.github/workflows/frontend.yml
.github/workflows/ventas.yml
.github/workflows/despachos.yml
```

---

## 🐳 Dockerfile - Frontend (React + Vite)

**Ubicación:** `front_despacho/Dockerfile`

### Características:
- **Multi-stage build**: 2 etapas
  - **Etapa 1 (builder)**: Node.js 20-alpine para compilar
  - **Etapa 2 (production)**: Nginx alpine para servir
- **Optimizaciones**:
  - Build solo lleva los archivos compilados
  - Imagen base pequeña (nginx:alpine)
  - Gzip compresión habilitada
  - Cache headers para assets estáticos
  - SPA routing configurado en Nginx

### Puerto: `80`

```bash
# Build manual
docker build -t tienda-frontend:latest ./front_despacho

# Run manual
docker run -p 80:80 tienda-frontend:latest
```

---

## 🐳 Dockerfile - Backend Ventas (Spring Boot)

**Ubicación:** `back-Ventas_SpringBoot/Springboot-API-REST/Dockerfile`

### Características:
- **Multi-stage build**: 2 etapas
  - **Etapa 1 (builder)**: Maven 3.9 con JDK 21 para compilar
  - **Etapa 2 (runtime)**: Eclipse Temurin 21-jre-alpine
- **Build Process**:
  - Ejecuta: `mvnw clean package -DskipTests`
  - Genera JAR ejecutable
- **Optimizaciones**:
  - JVM tuning: `-Xmx512m -Xms256m`
  - Health checks integrados
  - Imagen base minimal (alpine)

### Puerto: `8080`

```bash
# Build manual
docker build -t tienda-backend-ventas:latest ./back-Ventas_SpringBoot/Springboot-API-REST

# Run manual
docker run -p 8080:8080 tienda-backend-ventas:latest
```

---

## 🐳 Dockerfile - Backend Despachos (Spring Boot)

**Ubicación:** `back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO/Dockerfile`

### Características:
- Idéntico a Backend Ventas
- Compatible con arquitectura de microservicios

### Puerto: `8080` (mapeado a `8081` en docker-compose)

---

## 🐙 Docker Compose

**Ubicación:** `docker-compose.yml` (raíz del proyecto)

### Servicios:

#### 1. **Frontend**
```yaml
- container_name: tienda-frontend
- puerto: 80:80
- depends_on: backend-ventas, backend-despachos
```

#### 2. **Backend Ventas**
```yaml
- container_name: tienda-backend-ventas
- puerto: 8080:8080
- env: SPRING_PROFILES_ACTIVE=prod
```

#### 3. **Backend Despachos**
```yaml
- container_name: tienda-backend-despachos
- puerto: 8081:8080 (interno 8080, externo 8081)
- env: SPRING_PROFILES_ACTIVE=prod
```

### Red Docker
- **Nombre**: `tienda-network`
- **Driver**: bridge
- Permite comunicación entre contenedores por nombre

### Health Checks
Todos los servicios incluyen health checks que verifican:
- **Frontend**: Acceso a `/index.html`
- **Backends**: Acceso a `/actuator/health`

### Comandos Útiles

```bash
# Levantar todos los servicios
docker compose up --build

# Levantar en background
docker compose up -d --build

# Ver logs
docker compose logs -f

# Logs de un servicio específico
docker compose logs -f backend-ventas

# Detener servicios
docker compose down

# Detener y eliminar volúmenes
docker compose down -v

# Reconstruir una imagen
docker compose build --no-cache frontend
```

---

## 🚀 GitHub Actions Workflows

### Trigger
Todos los workflows se ejecutan en:
```
push en rama 'deploy'
```

### Requisitos Previos

1. **Variables de Entorno en GitHub Secrets**:
   - `DOCKER_USERNAME`: Tu usuario de Docker Hub
   - `DOCKER_PASSWORD`: Tu token/contraseña de Docker Hub

2. **Configurar Secrets**:
   - Ve a: `Settings > Secrets and variables > Actions`
   - Crea las variables anteriores

### 1. Frontend Workflow

**Archivo:** `.github/workflows/frontend.yml`

#### Pasos:
1. Checkout del código
2. Setup Docker Buildx (multi-arquitectura)
3. Login a Docker Hub
4. Build y Push de imagen:
   - Tag `latest`
   - Tag con SHA del commit
   - Cache de capas anterior
5. Scan de seguridad con Trivy
6. Upload de resultados

#### Triggers:
```yaml
paths:
  - 'front_despacho/**'
  - '.github/workflows/frontend.yml'
```

---

### 2. Backend Ventas Workflow

**Archivo:** `.github/workflows/ventas.yml`

#### Idéntico a frontend pero:
- Contexto: `./back-Ventas_SpringBoot/Springboot-API-REST`
- Imagen: `tienda-backend-ventas`
- Triggers: cambios en `back-Ventas_SpringBoot/**`

---

### 3. Backend Despachos Workflow

**Archivo:** `.github/workflows/despachos.yml`

#### Idéntico a ventas pero:
- Contexto: `./back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO`
- Imagen: `tienda-backend-despachos`
- Triggers: cambios en `back-Despachos_SpringBoot/**`

---

## 🔧 Configuración de Nginx

**Archivo:** `front_despacho/nginx.conf`

### Características:
- **SPA Routing**: `try_files $uri $uri/ /index.html`
- **Compresión**: Gzip para assets
- **Cache Busting**: 
  - Assets: 1 año (immutable)
  - HTML: Sin cache
- **Headers de Seguridad**:
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: SAMEORIGIN`
  - `X-XSS-Protection: 1; mode=block`
- **Logs separados**: Access y error logs

---

## 📝 Archivos .dockerignore

Creados en:
- `front_despacho/.dockerignore`
- `back-Ventas_SpringBoot/Springboot-API-REST/.dockerignore`
- `back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO/.dockerignore`

Excluyen archivos innecesarios para reducir tamaño de imagen.

---

## 🚀 Despliegue en AWS EC2

### Requisitos en la Instancia EC2

1. **Instalar Docker**:
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
```

2. **Clone del Repositorio**:
```bash
git clone https://github.com/tu-usuario/repo-tienda-eva2.git
cd repo-tienda-eva2
git checkout deploy
```

3. **Levantar Servicios**:
```bash
docker compose pull
docker compose up -d --build
```

4. **Verificar Estado**:
```bash
docker compose ps
docker compose logs -f
```

5. **Acceder a Servicios**:
- Frontend: `http://EC2_PUBLIC_IP:80`
- Backend Ventas: `http://EC2_PUBLIC_IP:8080`
- Backend Despachos: `http://EC2_PUBLIC_IP:8081`

### Security Groups en AWS
Abre los puertos:
- `80` (HTTP Frontend)
- `8080` (Backend Ventas)
- `8081` (Backend Despachos)
- `22` (SSH)

---

## 📊 Flujo CI/CD Completo

```
1. Developer hace push en rama 'deploy'
        ↓
2. GitHub Actions dispara los workflows
        ↓
3. Build Docker images para cada servicio
        ↓
4. Push a Docker Hub
        ↓
5. Escaneo de seguridad con Trivy
        ↓
6. Imagenes listas en Docker Hub
        ↓
7. EC2 descarga imagenes: docker compose pull
        ↓
8. Levanta servicios: docker compose up -d
        ↓
9. Health checks verifican que todo esté corriendo
```

---

## 🔍 Buenas Prácticas Implementadas

✅ **Dockerfile**:
- Multi-stage builds para reducir tamaño
- No usar `latest` internamente, usar versiones específicas
- Health checks configurados
- Metadata labels

✅ **Docker Compose**:
- Nombres de contenedores descriptivos
- Health checks para todos los servicios
- Dependencias definidas
- Red aislada
- Variables de entorno configurables

✅ **CI/CD**:
- Workflows separados por servicio
- Cache de capas Docker
- Tags con versión y SHA
- Escaneo de seguridad automático
- Secrets seguros (no hardcodeados)

✅ **Nginx**:
- SPA routing correcto
- Compresión habilitada
- Headers de seguridad
- Cache control inteligente

---

## ⚠️ Importante Antes de Usar

1. **Cambiar Docker Hub Username**:
   ```bash
   Buscar "tu-usuario-docker" en los workflows
   Reemplazar con tu usuario real de Docker Hub
   ```

2. **Configurar GitHub Secrets**:
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`

3. **Rama deploy**:
   - Los workflows solo se ejecutan en `push` a rama `deploy`
   - Asegúrate de usar esa rama para CI/CD

4. **Permisos**:
   - En GitHub: Actions debe tener permisos de lectura/escritura

---

## 📚 Comandos Rápidos

```bash
# Test local con docker-compose
docker compose up --build

# Ver todos los contenedores
docker ps

# Logs en tiempo real
docker compose logs -f backend-ventas

# Detener y limpiar
docker compose down -v

# Reconstruir una imagen
docker compose build --no-cache backend-despachos

# Acceder a contenedor
docker compose exec backend-ventas sh

# Push manual a Docker Hub (si necesario)
docker push tu-usuario-docker/tienda-frontend:latest
```

---

## 📞 Troubleshooting

### Frontend no muestra contenido
```bash
# Revisar logs
docker compose logs frontend

# Verificar Nginx
docker compose exec frontend nginx -t
```

### Backend no responde
```bash
# Revisar logs de la app
docker compose logs backend-ventas

# Verificar health check
docker compose exec backend-ventas wget -O - http://localhost:8080/actuator/health
```

### Permisos en EC2
```bash
# Ejecutar docker sin sudo
sudo usermod -aG docker $USER
newgrp docker
```

### Puerto ya en uso
```bash
# Encontrar proceso
lsof -i :8080

# Cambiar puerto en docker-compose.yml
# "8080:8080" → "8082:8080"
```

---

**Generado para evaluación DevOps universitaria** ✨
