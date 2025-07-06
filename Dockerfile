# syntax=docker/dockerfile:1.4

# Stage 1: Build and Test
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Leverage Docker layer caching + BuildKit cache for .m2
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:go-offline -B

COPY . .

RUN --mount=type=cache,target=/root/.m2 \
    mvn clean verify

# Stage 2: Production
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
