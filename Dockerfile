# Etapa 1: Build da aplicação com Maven e JDK 25
FROM maven:3.9.9-eclipse-temurin-25 AS build
WORKDIR /app

# Copia apenas o pom.xml primeiro para aproveitar o cache de dependências do Docker
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copia o código-fonte e gera o JAR executável
COPY src ./src
RUN mvn clean package -DskipTests -B

# Etapa 2: Imagem final enxuta apenas com JRE 25
FROM eclipse-temurin:25-jre
WORKDIR /app

# Cria usuário sem privilégios de root para segurança em produção
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Injeta a porta dinâmica do Render (PORT) e limita a RAM da JVM para o plano gratuito (512 MB)
ENTRYPOINT ["sh", "-c", "java -XX:MaxRAMPercentage=75.0 -Dserver.port=${PORT:-8080} -jar app.jar"]