ARG PLATFORM
FROM --platform=linux/${PLATFORM} amazoncorretto:17

COPY ./agent/codeguru-profiler-java-agent-standalone-1.2.3.jar /app/profiler-agent.jar
COPY ./target/world.jar /app/demo.jar
COPY ./agent/aws-opentelemetry-agent.jar /app/otel-agent.jar
COPY ./start-docker.sh /app/start-docker.sh