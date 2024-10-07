package demo.aws.hello;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoController {
    @Autowired
    private KafkaTemplate<String, String> template;

    @Autowired
    NewTopic mytopic;

    @PostMapping(path = "/send/{what}")
    public void sendFoo(@PathVariable String what) {
        this.template.send(mytopic.name(), new DataModel(what).toString());
    }
}
