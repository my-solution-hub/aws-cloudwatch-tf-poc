ARG PLATFORM
FROM --platform=linux/${PLATFORM} amazoncorretto:17

COPY ./target/hello.jar /app/demo.jar
COPY ./agent/aws-opentelemetry-agent.jar /app/otel-agent.jar
COPY ./start-docker.sh /app/start-docker.sh