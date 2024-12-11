# start.sh
# java -jar /app/demo.jar -Xmx400m -javaagent:/app/profiler-agent.jar=profilingGroupName:world,heapSummaryEnabled:true -javaagent:/app/otel-agent.jar &
java -javaagent:/app/otel-agent.jar -jar /app/demo.jar