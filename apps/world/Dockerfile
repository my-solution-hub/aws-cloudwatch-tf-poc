ARG PLATFORM
FROM --platform=linux/${PLATFORM} amazoncorretto:17

COPY ./agent/codeguru-profiler-java-agent-standalone-1.2.3.jar /app/profiler-agent.jar
COPY ./target/world.jar /app/demo.jar
COPY ./agents/opentelemetry-jmx-metrics.jar /app/jmx.jar
COPY ./agents/session.properties /app/session.properties
COPY ./start-docker.sh /app/start-docker.sh
