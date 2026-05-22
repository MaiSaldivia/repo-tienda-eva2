# ============================================
# Etapa 1: Build - Construcción con Maven
# ============================================
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copiar archivos de Maven
COPY pom.xml mvnw mvnw.cmd ./
COPY .mvn .mvn/

# Copiar código fuente
COPY src ./src

# Build del proyecto (skip tests)
RUN chmod +x ./mvnw && ./mvnw clean package -DskipTests

# ============================================
# Etapa 2: Runtime - Ejecución
# ============================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Información de mantenedor
LABEL maintainer="DevOps Team"
LABEL version="1.0"
LABEL description="API REST Despachos - Spring Boot Microservicio"

# Copiar JAR desde etapa anterior
COPY --from=builder /app/target/*.jar app.jar

# Exponer puerto 8080
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Variables de entorno por defecto
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Ejecutar la aplicación
ENTRYPOINT ["java"]
CMD ["-jar", "app.jar"]
