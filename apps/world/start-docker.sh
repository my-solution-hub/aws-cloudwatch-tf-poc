# start.sh
# java -jar /app/demo.jar -Xmx400m -javaagent:/app/otel-agent.jar -javaagent:/app/profiler-agent.jar=profilingGroupName:world,heapSummaryEnabled:true
java -Xmx400m -javaagent:/app/otel-agent.jar -javaagent:/app/profiler-agent.jar=profilingGroupName:world,heapSummaryEnabled:true -jar /app/demo.jar

# java -jar /app/demo.jar -Xmx400m -javaagent:/app/otel-agent.jar