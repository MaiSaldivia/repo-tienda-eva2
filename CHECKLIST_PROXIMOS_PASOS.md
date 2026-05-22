# ✅ CHECKLIST - PRÓXIMOS PASOS

## 🎯 QUÉ HACER AHORA

### Fase 1: Configuración Inmediata (5 minutos)

- [ ] **1. Obtener Docker Hub Token**
  - [ ] Ir a https://hub.docker.com/settings/security
  - [ ] Click "New Access Token"
  - [ ] Nombre: `github-actions`
  - [ ] Permisos: Read, Write, Delete
  - [ ] Copiar token generado

- [ ] **2. Configurar GitHub Secrets**
  - [ ] Ir a: `https://github.com/tu-usuario/repo-tienda-eva2/settings/secrets/actions`
  - [ ] Click "New repository secret"
  - [ ] Nombre: `DOCKER_USERNAME`
  - [ ] Valor: Tu usuario Docker Hub
  - [ ] Click "Add secret"
  - [ ] Repetir para `DOCKER_PASSWORD` con el token

- [ ] **3. Actualizar Workflows con tu Usuario Docker**
  - [ ] Abrir: `.github/workflows/frontend.yml`
  - [ ] Buscar: `tu-usuario-docker`
  - [ ] Reemplazar con tu usuario real (3 veces)
  - [ ] Repetir para `ventas.yml` y `despachos.yml`

### Fase 2: Test Local (10 minutos)

- [ ] **4. Crear rama 'deploy'**
  ```bash
  git checkout -b deploy
  git push origin deploy
  ```

- [ ] **5. Build y test local**
  ```bash
  docker compose up --build
  ```

- [ ] **6. Verificar servicios**
  - [ ] Frontend: http://localhost (debe cargar)
  - [ ] Backend Ventas: http://localhost:8080
  - [ ] Backend Despachos: http://localhost:8081

- [ ] **7. Detener servicios**
  ```bash
  docker compose down
  ```

### Fase 3: GitHub Actions (opcional test)

- [ ] **8. Hacer commit en rama deploy**
  ```bash
  git add .
  git commit -m "Add Docker and CI/CD structure"
  git push origin deploy
  ```

- [ ] **9. Verificar workflows**
  - [ ] Ir a: `https://github.com/tu-usuario/repo-tienda-eva2/actions`
  - [ ] Debería ver 3 workflows ejecutándose
  - [ ] Esperar a que terminen
  - [ ] Verificar que todos sean ✅ Green

### Fase 4: AWS EC2 (15-20 minutos)

- [ ] **10. Lanzar EC2 Instance**
  - [ ] AWS Console > EC2 > Launch Instance
  - [ ] OS: Ubuntu 22.04 LTS
  - [ ] Instance: t3.medium
  - [ ] Security Group: Crear nuevo
  - [ ] Download key pair (.pem)
  - [ ] Launch

- [ ] **11. Conectar a EC2**
  ```bash
  chmod 600 tu-key.pem
  ssh -i tu-key.pem ubuntu@ec2-ip
  ```

- [ ] **12. Instalar Docker**
  ```bash
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose-plugin
  sudo usermod -aG docker ubuntu
  newgrp docker
  ```

- [ ] **13. Clonar repositorio**
  ```bash
  git clone https://github.com/tu-usuario/repo-tienda-eva2.git
  cd repo-tienda-eva2
  git checkout deploy
  ```

- [ ] **14. Levantar aplicación**
  ```bash
  docker compose up -d --build
  docker compose logs -f
  ```

- [ ] **15. Configurar Security Group**
  - [ ] AWS Console > EC2 > Security Groups
  - [ ] Agregar Inbound Rules:
    - [ ] TCP 22 (SSH)
    - [ ] TCP 80 (Frontend)
    - [ ] TCP 8080 (Backend Ventas)
    - [ ] TCP 8081 (Backend Despachos)

- [ ] **16. Acceder a aplicación**
  ```
  Frontend:           http://ec2-ip
  Backend Ventas:     http://ec2-ip:8080
  Backend Despachos:  http://ec2-ip:8081
  ```

---

## 🔍 VERIFICACIÓN

### Local
```bash
# Servicios corriendo
docker compose ps

# Deben aparecer 3 containers:
# - tienda-frontend      (80)
# - tienda-backend-ventas (8080)
# - tienda-backend-despachos (8081)
```

### GitHub Actions
```
https://github.com/tu-usuario/repo-tienda-eva2/actions

Debe haber 3 workflows:
- frontend.yml ✅
- ventas.yml ✅
- despachos.yml ✅
```

### EC2
```bash
docker compose ps

# Mismos 3 containers corriendo
docker compose logs -f
```

---

## 📚 DOCUMENTACIÓN CREADA

Leer en este orden:

1. **ARCHIVOS_GENERADOS.md** (este archivo)
   - Resumen de todo lo creado
   - Ubicaciones exactas

2. **DOCKER_CICD_GUIDE.md**
   - Explicación detallada de cada componente
   - Comandos y ejemplos

3. **DESPLIEGUE_AWS.md**
   - Paso a paso para AWS EC2
   - Troubleshooting
   - Security best practices

---

## 🐛 PROBLEMAS COMUNES

| Problema | Solución |
|----------|----------|
| Workflows no ejecutan | Verificar rama es `deploy`, Secrets configurados |
| Puerto ya en uso | `docker compose down`, cambiar puerto en docker-compose.yml |
| Frontend no carga | `docker compose logs frontend`, verificar nginx.conf |
| Backend no responde | `docker compose logs backend-ventas`, verificar health check |
| EC2 no accede | Verificar Security Group, puertos abiertos |
| Docker no instala | Verificar Ubuntu version, permisos sudo |

---

## 💡 TIPS

**En local:**
```bash
# Alias útil
alias dc="docker compose"
dc up -d
dc logs -f
dc ps
```

**En GitHub:**
```
Settings > Actions > General
- Habilitar "Read and write permissions"
- Habilitar "Allow GitHub Actions to create and approve PRs"
```

**En AWS:**
```bash
# Ver logs en tiempo real
docker compose logs -f

# Actualizar desde repo
git pull
docker compose pull
docker compose up -d
```

---

## 🎓 PARA LA EVALUACIÓN

El profesor debe ver:

✅ **Dockerfiles**
- [ ] 3 Dockerfiles creados
- [ ] Multi-stage builds
- [ ] Optimizados para producción

✅ **Docker Compose**
- [ ] docker-compose.yml funcional
- [ ] 3 servicios configurados
- [ ] Network y health checks

✅ **GitHub Actions**
- [ ] 3 workflows creados
- [ ] Funcionan en rama deploy
- [ ] Push automático a Docker Hub
- [ ] Security scanning

✅ **AWS EC2**
- [ ] Aplicación corriendo
- [ ] Todos los servicios accesibles
- [ ] Health checks passing

✅ **Documentación**
- [ ] DOCKER_CICD_GUIDE.md completo
- [ ] DESPLIEGUE_AWS.md con instrucciones
- [ ] ARCHIVOS_GENERADOS.md con inventario

---

## 📊 INFORMACIÓN IMPORTANTE

### Nombres de Servicios (docker-compose)
- Frontend: `tienda-frontend` 
- Backend Ventas: `tienda-backend-ventas`
- Backend Despachos: `tienda-backend-despachos`

### Puertos
- Frontend: `80`
- Backend Ventas: `8080`
- Backend Despachos: `8081` (mapeado a 8080 interno)

### Imágenes Docker Hub
```
tu-usuario-docker/tienda-frontend:latest
tu-usuario-docker/tienda-backend-ventas:latest
tu-usuario-docker/tienda-backend-despachos:latest
```

### Rama para CI/CD
`deploy` (obligatoria)

### Secrets necesarios
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

---

## 🚀 ÉXITO GARANTIZADO

Con esta estructura:
✅ Toda la infraestructura Docker está
✅ CI/CD automático con GitHub Actions
✅ Despliegue en AWS EC2 lista
✅ Documentación completa
✅ Buenas prácticas DevOps

**Tiempo estimado completar:
- Configuración: 5 minutos
- Test local: 10 minutos
- Deploy AWS: 20 minutos
- TOTAL: ~35 minutos**

---

## 📞 DUDAS FRECUENTES

**P: ¿Por qué 3 workflows?**
A: Cada servicio independiente permite builds más rápidos y granularidad.

**P: ¿Puedo cambiar los puertos?**
A: Sí, editar `docker-compose.yml` (puerto izquierda es el expuesto)

**P: ¿Qué pasa si no tengo Docker Hub?**
A: Crear cuenta en https://hub.docker.com (gratis)

**P: ¿Necesito AWS para test local?**
A: No, `docker compose up` funciona en tu máquina

**P: ¿Los workflows se ejecutan automáticamente?**
A: Solo en push a rama `deploy`, no en otras ramas

---

**¡Listo para empezar! 🚀**

Tiempo total: ~35 minutos para evaluación completa
