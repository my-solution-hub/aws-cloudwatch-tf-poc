ARG PLATFORM
FROM --platform=linux/${PLATFORM} amazoncorretto:17

COPY ./agent/codeguru-profiler-java-agent-standalone-1.2.3.jar /app/profiler-agent.jar
COPY ./target/world.jar /app/demo.jar
# COPY ./agent/opentelemetry-jmx-metrics.jar /app/jmx.jar
# COPY ./agent/session.properties /app/session.properties
COPY ./agent/jmx_prometheus_javaagent.jar /app/jmx_exporter.jar
COPY ./agent/config.yaml /app/config.yaml
COPY ./start-docker.sh /app/start-docker.sh
