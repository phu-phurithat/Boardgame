# ---- Build and Test Stage ----
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

WORKDIR /build

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests=false

# ---- Runtime Stage ----
FROM openjdk:17-alpine

ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME

COPY --from=build /build/target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
