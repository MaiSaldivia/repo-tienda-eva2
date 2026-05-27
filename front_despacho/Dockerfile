# ============================================
# Etapa 1: Build - Construcción con Node.js
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# COPIAR archivos de dependencias
COPY package.json package-lock.json ./

# Instalar dependencias
RUN npm ci

# Copiar código FUENTE
COPY . .

# Build de la aplicación Vite
RUN npm run build

# ============================================
# Etapa 2: Production - Nginx
# ============================================
FROM nginx:alpine

# Copiar configuración de Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar archivos compilados desde la etapa anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponer puerto 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/index.html || exit 1

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]
