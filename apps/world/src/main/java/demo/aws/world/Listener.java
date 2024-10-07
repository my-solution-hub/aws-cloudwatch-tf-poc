package demo.aws.world;

import org.springframework.kafka.annotation.KafkaListener;

public class Listener {
    @KafkaListener(id = "myId", topics = "cloudwatch-poc")
    public void listen(String in) {
        System.out.println(in);
    }
}
