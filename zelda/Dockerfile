FROM maven:3.8.2-adoptopenjdk-11 as builder

# Go to usr/local/app and copy files into it
WORKDIR /usr/local/app
COPY . ./

RUN mvn dependency:go-offline
RUN mvn -Dmaven.test.skip=true package

FROM openjdk:11
WORKDIR /usr/local/app
COPY --from=builder /usr/local/app/target/zelda-1.0-SNAPSHOT-jar-with-dependencies.jar ./zelda.jar

CMD [ "java", "-jar", "zelda.jar" ]