# Etapa 1: Build da aplicação com JDK 25 + Maven Wrapper do projeto
FROM eclipse-temurin:25-jdk AS build
WORKDIR /app

# Copia o Maven Wrapper e o pom.xml para aproveitar o cache de dependências do Docker
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copia o código-fonte e gera o JAR executável
COPY src ./src
RUN ./mvnw clean package -DskipTests -B

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