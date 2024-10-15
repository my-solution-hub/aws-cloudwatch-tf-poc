ARG PLATFORM
FROM --platform=linux/${PLATFORM} amazoncorretto:17

COPY ./agent/codeguru-profiler-java-agent-standalone-1.2.3.jar /app/profiler-agent.jar
COPY ./target/world.jar /app/demo.jar
# WORKDIR /app
ENTRYPOINT ["java", "-javaagent:/app/profiler-agent.jar=profilingGroupName:world,heapSummaryEnabled:true", "-jar", "/app/demo.jar"]