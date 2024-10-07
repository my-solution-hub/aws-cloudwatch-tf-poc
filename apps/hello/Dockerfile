ARG PLATFORM
FROM --platform=linux/${PLATFORM} amazoncorretto:17

COPY ./target/hello.jar /app/demo.jar
# WORKDIR /app
ENTRYPOINT ["java", "-jar", "/app/demo.jar"]