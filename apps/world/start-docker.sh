# start.sh
java -jar /app/demo.jar -Xmx400m -javaagent:/app/profiler-agent.jar=profilingGroupName:world,heapSummaryEnabled:true &
java -jar /app/jmx.jar -config /app/session.properties
