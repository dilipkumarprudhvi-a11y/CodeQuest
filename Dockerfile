# ----------------------------------------------------
# Stage 1: Build WAR with Maven & JDK 17
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

# Clean default webapps to serve CodeQuest at root '/'
RUN rm -rf webapps/ROOT webapps/docs webapps/examples webapps/manager webapps/host-manager

# Copy compiled WAR as ROOT.war so CodeQuest responds on / instead of /CodeQuest/
COPY --from=builder /app/target/CodeQuest.war webapps/ROOT.war

# Dynamic PORT adapter script for cloud providers (Render, Railway, Heroku)
RUN printf '#!/bin/sh\nif [ -n "$PORT" ]; then\n  sed -i "s/port=\\"8080\\"/port=\\"$PORT\\"/g" conf/server.xml\nfi\nexec catalina.sh run\n' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
