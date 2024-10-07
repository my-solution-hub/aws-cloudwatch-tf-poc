package demo.aws.world;

import org.springframework.kafka.annotation.KafkaListener;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPooled;

public class Listener {
    @KafkaListener(id = "myId", topics = "cloudwatch-poc")
    public void listen(String in) {
        System.out.println(in);
        System.out.println(storeData(in));

    }

    public String storeData(String message){
        Jedis jedis = new Jedis(String.format("%s://%s:%s", System.getenv("REDIS_PROTOCOL"),System.getenv("REDIS_HOST"),System.getenv("REDIS_PORT")));
        try{

            jedis.auth(System.getenv("REDIS_USER"), System.getenv("REDIS_PASS"));
            // System.out.println(jedis.ping());
            jedis.set("demo", message);
            return jedis.get("demo");
        }
        finally {
            jedis.close();
        }
    }
}
