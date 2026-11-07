# 🚀 Multi-stage Dockerfile for Batwa Wallet Spring Boot Service (Hugging Face & Cloud Ready)
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Build application
COPY src ./src
RUN mvn clean package -DskipTests

# Run lightweight JRE container
FROM eclipse-temurin:17-jre-alpine

# Run as non-root user (Hugging Face UID 1000 standard)
RUN adduser -u 1000 -D appuser
WORKDIR /app

COPY --from=build --chown=appuser:appuser /app/target/*.jar app.jar

USER appuser

EXPOSE 7860
ENV PORT=7860

ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT} -jar app.jar"]
