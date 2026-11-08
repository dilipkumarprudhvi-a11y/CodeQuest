# ----------------------------------------------------
# Stage 1: Build Java WAR with Maven & JDK 17
# ----------------------------------------------------
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# ----------------------------------------------------
# Stage 2: Apache Tomcat 10.1 (Jakarta EE 10)
# ----------------------------------------------------
FROM tomcat:10.1-jdk17-temurin
WORKDIR /usr/local/tomcat

# Clean default webapps so CodeQuest serves at root '/'
RUN rm -rf webapps/ROOT webapps/docs webapps/examples webapps/manager webapps/host-manager

# Copy compiled WAR as ROOT.war
COPY --from=builder /app/target/CodeQuest.war webapps/ROOT.war

# Copy cloud entrypoint script to handle dynamic $PORT and disable shutdown port
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8080 10000
ENTRYPOINT ["/docker-entrypoint.sh"]
