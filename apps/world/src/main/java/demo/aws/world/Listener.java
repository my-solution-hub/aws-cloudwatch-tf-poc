package demo.aws.world;

import java.util.HashSet;
import java.util.Set;

import org.apache.commons.pool2.impl.GenericObjectPoolConfig;
import org.springframework.kafka.annotation.KafkaListener;

import redis.clients.jedis.HostAndPort;
import redis.clients.jedis.JedisCluster;

public class Listener {
    @KafkaListener(id = "myId", topics = "cloudwatch-poc")
    public void listen(String in) {
        System.out.println("consume: " + in);
        System.out.println("retrieve from redis: " + storeData(in));

    }

    public String storeData(String message){
        Set<HostAndPort> jedisClusterNodes = new HashSet<HostAndPort>();

        // JedisCluster(HostAndPort node, int connectionTimeout, int soTimeout, int maxAttempts, String user, String password, String clientName, org.apache.commons.pool2.impl.GenericObjectPoolConfig<Jedis> poolConfig, boolean ssl) 
        jedisClusterNodes.add(new HostAndPort(System.getenv("REDIS_HOST"), Integer.parseInt(System.getenv("REDIS_PORT"))));

        JedisCluster jedisCluster = new JedisCluster(jedisClusterNodes, 30, 30, 3, System.getenv("REDIS_USER"), System.getenv("REDIS_PASS"), "hello", new GenericObjectPoolConfig<>(), true);
        try {
            jedisCluster.append("demo", message);
            return jedisCluster.get("demo");
        }
        finally {
            jedisCluster.close();
        }
        
    }
}
