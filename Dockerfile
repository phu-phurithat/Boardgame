# Stage 1: Build and Test
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app
# Copy pom.xml first to leverage Docker layer caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Now copy the rest of the source code
COPY . .

# Build and test the application
RUN mvn clean verify

# Stage 2: Production

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
