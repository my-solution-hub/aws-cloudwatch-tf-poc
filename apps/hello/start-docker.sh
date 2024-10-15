# start.sh
java -javaagent:/app/jmx_exporter.jar=9404:/app/config.yaml -jar -javaagent:/app/jmx_exporter.jar=9404:/app/config.yaml /app/demo.jar