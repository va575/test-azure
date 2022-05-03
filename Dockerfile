#Stage 1
# initialize build and set base image for first stage
FROM maven:3.8.5-openjdk-8 as stage1
# speed up Maven JVM a bit
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
# set working directory
WORKDIR /opt/demo
# copy just pom.xml
COPY pom.xml .
# go-offline using the pom.xml
RUN mvn dependency:go-offline
# copy your other files
COPY ./src ./src
# compile the source code and package it in a jar file
RUN mvn clean install -Dmaven.test.skip=true
#Stage 2
# set base image for second stage
FROM adoptopenjdk/openjdk8:jre8u292-b10-alpine as stage2
# set deployment directory
WORKDIR /opt/demo
# copy over the built artifact from the maven image
COPY --from=stage1 /opt/demo/target/demo-0.0.1-SNAPSHOT.jar /opt/demo

EXPOSE 8080

ENTRYPOINT ["java","-jar","/opt/demo/demo-0.0.1-SNAPSHOT.jar"]
