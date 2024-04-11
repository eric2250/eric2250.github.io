# Rabbitmq使用实践

## 1.简单模式

### 新建生产者

```
package com.eric.rabbitmq.simpe;

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;

import java.nio.charset.StandardCharsets;

public class Producer {
    //队列名称
    public static  final  String QUEUE_NAME = "hello";
    //发消息
    public static void main(String[] args) throws Exception{
        //创建连接工厂
        ConnectionFactory factory = new ConnectionFactory();
        //工厂IP 连接mq队列
        factory.setHost("172.100.2.13");
        //用户名和密码
        factory.setUsername("admin");
        factory.setPassword("admin");
        //创建连接
        Connection connection = factory.newConnection();
        //获取信道
        Channel channel = connection.createChannel();
        //生产队列
        channel.queueDeclare(QUEUE_NAME, false,false,false,null);
        //发消息
        String msg = "Hello,eric";
        channel.basicPublish("",QUEUE_NAME,null,msg.getBytes());
        System.out.println("消息发送完毕");

    }
}

```

### 新建消费者

```
package com.eric.rabbitmq.simpe;

import com.rabbitmq.client.*;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

public class Consumer {
    //队列名称
    public static  final  String QUEUE_NAME = "hello";

    public static void main(String[] args) throws IOException, TimeoutException {
        //创建连接工厂
        ConnectionFactory factory = new ConnectionFactory();
        //工厂IP 连接mq队列
        factory.setHost("172.100.2.13");
        //用户名和密码
        factory.setUsername("admin");
        factory.setPassword("admin");
        //创建连接
        Connection connection = factory.newConnection();
        //获取信道
        Channel channel = connection.createChannel();
        //声明，接收消息
        DeliverCallback deliverCallback = (consumerTag,message)->{
            System.out.println(message);
        };
        CancelCallback cancelCallback = consumerTag->{
          System.out.println("消息消费被中断");
        };
        //接收消息
        channel.basicConsume(QUEUE_NAME,true,deliverCallback,cancelCallback);
    }
}

```

运行后去控制台查看：http://172.100.2.13:15672/#/queues 

## 2.work模式

### 2.1 轮询

#### 生产者：

```
package com.eric.rabbitmq.work.lunxun;


import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.Channel;

import java.util.Scanner;

public class Producers {
    //队列名称
    public static  final  String QUEUE_NAME = "hello";
    //发消息
    public static void main(String[] args) throws Exception{
        Channel channel = RabbitMqUtils.getChannel();
        //生成队列
        channel.queueDeclare(QUEUE_NAME, false,false,false,null);
        //发消息
        //接收输入消息
        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNext()){
            String message = scanner.next();
            channel.basicPublish("",QUEUE_NAME,null,message.getBytes());
            System.out.println("消息发送完毕");
        }
    }
}

```

#### 消费者1：

```
package com.eric.rabbitmq.work.lunxun;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.CancelCallback;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class Work01 {
    //队列名称
    public static  final  String QUEUE_NAME = "hello";

    public static void main(String[] args) throws Exception {
        Channel channel = RabbitMqUtils.getChannel();
        //声明，接收消息
        DeliverCallback deliverCallback = (consumerTag, message)->{
            System.out.println("接收到的消息:"+ new String(message.getBody()));
        };
        CancelCallback cancelCallback = consumerTag->{
            System.out.println(consumerTag + "消息消费被中断");
        };
        System.out.println("C1等待接收消息.....");
        channel.basicConsume(QUEUE_NAME,true,deliverCallback,cancelCallback);
    }
}

```

#### 消费者2：

```
package com.eric.rabbitmq.work.lunxun;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.CancelCallback;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class Work02 {
    //队列名称
    public static  final  String QUEUE_NAME = "hello";

    public static void main(String[] args) throws Exception {
        Channel channel = RabbitMqUtils.getChannel();
        //声明，接收消息
        DeliverCallback deliverCallback = (consumerTag, message)->{
            System.out.println("接收到的消息:"+ new String(message.getBody()));
        };
        CancelCallback cancelCallback = consumerTag->{
            System.out.println(consumerTag + "消息消费被中断");
        };
        System.out.println("C2等待接收消息.....");
        channel.basicConsume(QUEUE_NAME,true,deliverCallback,cancelCallback);
    }
}

```

### 2.2 按权重分发

以后P代表生产者。C代表消费者，前提开启手动应答

新建创建信道类，以便调用

```
package com.eric.rabbitmq.utils;

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
public class RabbitMqUtils {
    public static Channel getChannel() throws Exception {
        //创建连接工厂
        ConnectionFactory factory = new ConnectionFactory();
        //工厂IP 连接mq队列
        factory.setHost("172.100.2.13");
        //用户名和密码
        factory.setUsername("admin");
        factory.setPassword("admin");
        //创建连接
        Connection connection = factory.newConnection();
        //获取信道
        Channel channel = connection.createChannel();
        return channel;
    }
}

```

沉睡类，模拟超时

```
package com.eric.rabbitmq.utils;

public class SleepUtils {
    public static void sleep(int second){
        try{
            Thread.sleep(second*1000);
        }catch (InterruptedException _ignored){
            Thread.currentThread().interrupt();
        }
    }
}

```

#### P：

```
package com.eric.rabbitmq.work.fair;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.MessageProperties;

import java.util.Scanner;

//消息手动应答不丢失，放回队列重新消费
public class Task2 {
    public static final String task_queue_name = "ack_queue";

    public static void main(String[] args) throws Exception {

        Channel channel = RabbitMqUtils.getChannel();
        //生成队列
        boolean durable = true;   //队列持久化
        channel.queueDeclare(task_queue_name, durable, false, false, null);
        System.out.println("创建队列" + task_queue_name + "完成");

        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNext()) {
            String message = scanner.next();
            //MessageProperties.PERSISTENT_TEXT_PLAIN 消息持久化
            channel.basicPublish("", task_queue_name, MessageProperties.PERSISTENT_TEXT_PLAIN, message.getBytes("UTF-8"));
            System.out.println("消息发送完毕" + message);
        }
    }
}

```

#### C1:

处理时间短，能力为2

```
package com.eric.rabbitmq.work.fair;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.eric.rabbitmq.utils.SleepUtils;
import com.rabbitmq.client.CancelCallback;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class Work03 {
    //队列名称
    public static  final  String task_queue_name = "ack_queue";

    public static void main(String[] args) throws Exception {
        Channel channel = RabbitMqUtils.getChannel();
        System.out.println("C3等待接收消息处理时间较短");
        //声明，接收消息
        DeliverCallback deliverCallback = (consumerTag, message)->{
            //睡1S
            SleepUtils.sleep(1);
            System.out.println("接收到的消息:"+ new String(message.getBody(),"UTF-8"));
            //手动应答
            channel.basicAck(message.getEnvelope().getDeliveryTag(),false);
        };
        //设置不公平分发，实现多劳多得
        int prefetchCount = 2;
        channel.basicQos(prefetchCount);
        //采取手动应答
        boolean autoAck = false;
        channel.basicConsume(task_queue_name,autoAck,deliverCallback,(consumerTag ->{
            System.out.println(consumerTag + "消费者取消消费接口回调逻辑");
        }));
    }
}

```

#### C2:

```
package com.eric.rabbitmq.work.fair;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.eric.rabbitmq.utils.SleepUtils;
import com.rabbitmq.client.CancelCallback;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class Work04 {
    //队列名称
    public static  final  String task_queue_name = "ack_queue";

    public static void main(String[] args) throws Exception {
        Channel channel = RabbitMqUtils.getChannel();
        System.out.println("C4等待接收消息处理时间较长");
        //声明，接收消息
        DeliverCallback deliverCallback = (consumerTag, message)->{
            //睡30S
            SleepUtils.sleep(30);
            System.out.println("接收到的消息:"+ new String(message.getBody(),"UTF-8"));
            //手动应答
            channel.basicAck(message.getEnvelope().getDeliveryTag(),false);
        };
        //设置不公平分发，实现多劳多得
        int prefetchCount = 5;
        channel.basicQos(prefetchCount);
        //采取手动应答
        boolean autoAck = false;
        channel.basicConsume(task_queue_name,autoAck,deliverCallback,(consumerTag ->{
            System.out.println(consumerTag + "消费者取消消费接口回调逻辑");
        }));
    }
}

```

### 3.消息确认

```
package com.eric.rabbitmq.work.confirm;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.CancelCallback;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.ConfirmCallback;

import java.util.UUID;
import java.util.concurrent.ConcurrentNavigableMap;
import java.util.concurrent.ConcurrentSkipListMap;

//发布确认
public class ConfirmMessage {

    //发消息个数
    public static final int MESSAGE_COUNT = 1000;

    public static void main(String[] args) throws Exception {
        //单个确认
        //ConfirmMessage.publishMessageIndividually();
        //批量确认
        //ConfirmMessage.publishMessageIndividually();
        //异步确认
        ConfirmMessage.publishAsync();

    }

    //单个确认
    public static void publishMessageIndividually() throws Exception {
        Channel channel = RabbitMqUtils.getChannel();
        //队列声明
        String queueName = UUID.randomUUID().toString();
        channel.queueDeclare(queueName, true, false, false, null);
        //开启发布确认
        channel.confirmSelect();
        //开始时间
        long begin = System.currentTimeMillis();
        //批量发消息
        for (int i = 0; i < MESSAGE_COUNT; i++) {
            String message = i + "";
            channel.basicPublish("", queueName, null, message.getBytes());
            //确认发布
            boolean flag = channel.waitForConfirms();
/*            if (flag) {
                System.out.println("消息发布成功");
            }*/
        }
        //结束时间
        long end = System.currentTimeMillis();
        System.out.println("发布" + MESSAGE_COUNT + "个单独确认消息，耗时" + (end - begin) + "ms");
    }

    //批量确认
    public static void publishMessageBatch() throws Exception {
        Channel channel = RabbitMqUtils.getChannel();
        //队列声明
        String queueName = UUID.randomUUID().toString();
        channel.queueDeclare(queueName, true, false, false, null);
        //开启发布确认
        channel.confirmSelect();
        //开始时间
        long begin = System.currentTimeMillis();
        //批量确认消息大小
        int batchSize = 100;

        //批量发消息
        for (int i = 0; i < MESSAGE_COUNT; i++) {
            String message = i + "";
            channel.basicPublish("", queueName, null, message.getBytes());

            //判断每100条消息确认一次
            if (i % batchSize == 0) {
                //发布确认
                channel.waitForConfirms();
                //System.out.println("消息发布成功");
            }
        }
/*        //确认发布
        boolean flag = channel.waitForConfirms();
        if (flag){
            System.out.println("消息发布成功");
        }*/
        //结束时间
        long end = System.currentTimeMillis();
        System.out.println("发布" + MESSAGE_COUNT + "个批量确认消息，耗时" + (end - begin) + "ms");
    }

    //异步发送确认
    public static void publishAsync() throws Exception {
        Channel channel = RabbitMqUtils.getChannel();
        //队列声明
        String queueName = UUID.randomUUID().toString();
        channel.queueDeclare(queueName, true, false, false, null);
        //开启发布确认
        channel.confirmSelect();
        /*
         * 准备map
         * */
        ConcurrentSkipListMap<Long, String> outstandingConfirms =
                new ConcurrentSkipListMap<>();

        //消息确认成功，回调函数
        ConfirmCallback ackCallback = (deliveryTag, multiple) -> {
            if (multiple){
                //删除 确认的消息
                ConcurrentNavigableMap<Long,String> confirmed = outstandingConfirms.headMap(deliveryTag);
                confirmed.clear();
            }else {
                outstandingConfirms.remove(deliveryTag);
            }
            System.out.println("确认的消息" + deliveryTag);
        };
        //消息确认失败，回调函数
        ConfirmCallback nacCallback = (deliveryTag, multiple) -> {
            String message = outstandingConfirms.get(deliveryTag);
            System.out.println("未确认的消息是:" + message + "未确认的消息tag:" + deliveryTag);
        };
        //准备消息监听器
        channel.addConfirmListener(ackCallback, nacCallback);//异步通知
        //开始时间
        long begin = System.currentTimeMillis();
        //批量发消息
        for (int i = 0; i < MESSAGE_COUNT; i++) {
            String message = "消息" + i;
            channel.basicPublish("", queueName, null, message.getBytes());
            //记录消息至map
            outstandingConfirms.put(channel.getNextPublishSeqNo(),message);
        }
        //结束时间
        long end = System.currentTimeMillis();
        System.out.println("发布" + MESSAGE_COUNT + "个异步确认消息，耗时" + (end - begin) + "ms");
    }
}

```

## 3.交换机

### 3.1 直接交换机direct

根据routing-key绑定不同队列发送到不同的队列

#### P：

```
package com.eric.rabbitmq.direct;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;

import java.util.Scanner;

public class EmitLog {
    public static final String EXCHANGE_NAME = "direct_logs";
    public static final String ROUTING_KEY = "info";//info or error

    public static void main(String[] args) throws Exception{
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME,  BuiltinExchangeType.DIRECT);
       //输入消息
        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNext()){
            String message = scanner.next();
            channel.basicPublish(EXCHANGE_NAME,ROUTING_KEY,null,message.getBytes("UTF-8"));
            System.out.println("发送消息："+ message);
        }
    }
}

```

#### C1：

```
package com.eric.rabbitmq.direct;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class ReceiveLog1 {
    public static final String EXCHANGE_NAME = "direct_logs";

    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME, BuiltinExchangeType.DIRECT);
        //声明队列。
        String queueName ="console";
        channel.queueDeclare(queueName,false,false,false,null);
        //banding
        channel.queueBind(queueName, EXCHANGE_NAME, "info");
        System.out.println("1等待接收消息");

        //接收消息
        DeliverCallback deliverCallback = (consumerTag, message) -> {
            System.out.println("1打印消息:" + new String(message.getBody(), "UTF-8"));
        };
        channel.basicConsume(queueName, true, deliverCallback,consumerTag->{});
    }

}

```

#### C2：

```
package com.eric.rabbitmq.direct;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class ReceiveLog2 {
    public static final String EXCHANGE_NAME = "direct_logs";

    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME,  BuiltinExchangeType.DIRECT);
        //声明队列。
        String queueName ="disk";
        channel.queueDeclare(queueName,false,false,false,null);
        //banding
        channel.queueBind(queueName, EXCHANGE_NAME, "error");
        System.out.println("2等待接收消息");

        //接收消息
        DeliverCallback deliverCallback = (consumerTag, message) -> {
            System.out.println("2打印消息:" + new String(message.getBody(), "UTF-8"));
        };
        channel.basicConsume(queueName, true, deliverCallback,consumerTag->{});
    }

}

```

### 3.2 fanout交换机

绑定队列都能收到消息

#### P：

```
package com.eric.rabbitmq.fanout;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.Channel;

import java.util.Scanner;

public class EmitLog {
    public static final String EXCHANGE_NAME = "logs";
    public static void main(String[] args) throws Exception{
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        //channel.exchangeDeclare(EXCHANGE_NAME, "fanout");
       //输入消息
        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNext()){
            String message = scanner.next();
            channel.basicPublish(EXCHANGE_NAME,"",null,message.getBytes("UTF-8"));
            System.out.println("发送消息："+ message);
        }
    }
}

```

#### C1：

```
package com.eric.rabbitmq.fanout;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class ReceiveLog1 {
    public static final String EXCHANGE_NAME = "logs";

    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME, "fanout");
        //声明队列。临时队列。
        String queueName = channel.queueDeclare().getQueue();
        //banding
        channel.queueBind(queueName, EXCHANGE_NAME, "");
        System.out.println("1等待接收消息");

        //接收消息
        DeliverCallback deliverCallback = (consumerTag, message) -> {
            System.out.println("1打印消息:" + new String(message.getBody(), "UTF-8"));
        };
        channel.basicConsume(queueName, true, deliverCallback,consumerTag->{});
    }

}

```



#### C2：

```
package com.eric.rabbitmq.fanout;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class ReceiveLog2 {
    public static final String EXCHANGE_NAME = "logs";

    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME, "fanout");
        //声明队列。临时队列。
        String queueName = channel.queueDeclare().getQueue();
        //banding
        channel.queueBind(queueName, EXCHANGE_NAME, "");
        System.out.println("2等待接收消息");

        //接收消息
        DeliverCallback deliverCallback = (consumerTag, message) -> {
            System.out.println("2打印消息:" + new String(message.getBody(), "UTF-8"));
        };
        channel.basicConsume(queueName, true, deliverCallback,consumerTag->{});
    }

}

```

### 3.3 TOPIC交换机

根据规则分发消息

#### P:

```
package com.eric.rabbitmq.topics;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;

import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class EmitLog {
    public static final String EXCHANGE_NAME = "topic_logs";
    public static final String ROUTING_KEY = "lazy.orange.rabbit";//orange or rabbit lazy

    public static void main(String[] args) throws Exception{
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME,  BuiltinExchangeType.TOPIC);
       //输入消息
/*        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNext()){
            String message = scanner.next();
            channel.basicPublish(EXCHANGE_NAME,ROUTING_KEY,null,message.getBytes("UTF-8"));
            System.out.println("发送消息："+ message);
        }*/
        //定义一个发消息map
        Map<String,String>bindingKeyMap = new HashMap<>();
        bindingKeyMap.put("quick.orange.rabbit","被队列Q1Q2接收到");
        bindingKeyMap.put("lazy.orange.elephant","被队列Q1Q2接收到");
        bindingKeyMap. put("quick.orange.fox","被队列Q1接收到");
        bindingKeyMap.put("lazy.brown.fox","被队列Q2接收到");
        bindingKeyMap.put("lazy.pink.rabbit","虽然满足两个绑定但只被队列Q2接收一次");
        bindingKeyMap. put("quick.brown.fox","不匹配任何绑定不会被任何队列接收到会被丢弃");
        bindingKeyMap. put("quick.orange.male.rabbit","是四个单词不匹配任何绑定会被丢弃");
        bindingKeyMap. put("lazy.orange.male.rabbit","是四个单词但匹配Q2");

        for (Map.Entry<String,String>bindingKeyEntry: bindingKeyMap.entrySet()){
            String routingKey = bindingKeyEntry.getKey();
            String message = bindingKeyEntry.getValue();
            channel.basicPublish(EXCHANGE_NAME,routingKey,null,message.getBytes("UTF-8"));
            System.out.println("发出消息："+ message);
        }
    }
}

```

#### C1：

```
package com.eric.rabbitmq.topics;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class ReceiveLog1 {
    public static final String EXCHANGE_NAME = "topic_logs";
    public static final String ROUTING_KEY = "*.orange.*";//匹配中间包含orange的三个单词

    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME, BuiltinExchangeType.TOPIC);
        //声明队列。
        String queueName ="console";
        channel.queueDeclare(queueName,false,false,false,null);
        //banding
        channel.queueBind(queueName, EXCHANGE_NAME, ROUTING_KEY);
        System.out.println("1等待接收消息");

        //接收消息
        DeliverCallback deliverCallback = (consumerTag, message) -> {
            System.out.println("1打印消息:" + new String(message.getBody(), "UTF-8"));
        };
        channel.basicConsume(queueName, true, deliverCallback,consumerTag->{});
    }

}

```

#### C2：

```
package com.eric.rabbitmq.topics;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

public class ReceiveLog2 {
    public static final String EXCHANGE_NAME = "topic_logs";
    public static final String ROUTING_KEY1 = "*.*.rabbit";//匹配rabbit结尾的三个单词
    public static final String ROUTING_KEY2 = "lazy.#";//匹配lazy开头的N个单词

    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME,  BuiltinExchangeType.TOPIC);
        //声明队列。
        String queueName ="disk";
        channel.queueDeclare(queueName,false,false,false,null);
        //banding
        channel.queueBind(queueName, EXCHANGE_NAME, ROUTING_KEY1);
        channel.queueBind(queueName, EXCHANGE_NAME, ROUTING_KEY2);
        System.out.println("2等待接收消息");

        //接收消息
        DeliverCallback deliverCallback = (consumerTag, message) -> {
            System.out.println("2打印消息:" + new String(message.getBody(), "UTF-8"));
        };
        channel.basicConsume(queueName, true, deliverCallback,consumerTag->{});
    }

}

```

## 4.死信队列

### P：

```
package com.eric.rabbitmq.deadqueue;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.AMQP;
import com.rabbitmq.client.Channel;

import java.util.Scanner;

public class Producer {
    public static final String NORMAL_EXCHANGE = "normal_exchange";

    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //发送消息
        //死信队列 设置TTL时间,10s过期
        AMQP.BasicProperties properties =
                new AMQP.BasicProperties()
                        .builder().expiration("10000").build();

        for (int i = 1; i < 11; i++) {
            String message = "info" + i;
            channel.basicPublish(NORMAL_EXCHANGE, "zhangsan", properties, message.getBytes());
            System.out.println(i);
        }
    }
}

```

#### C1：

```
package com.eric.rabbitmq.deadqueue;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

import java.util.HashMap;
import java.util.Map;
/*
* 死信队列实验
* */
public class Consumer01 {
    public static final String NORMAL_EXCHANGE = "normal_exchange";
    public static final String DEAD_EXCHANGE = "dead_exchange";
    public static final String NORMAL_QUEUE = "normal_queue";
    public static final String DEAD_QUEUE = "dead_queue";


    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        //声明交换机
        channel.exchangeDeclare(NORMAL_EXCHANGE, BuiltinExchangeType.DIRECT);
        channel.exchangeDeclare(DEAD_EXCHANGE, BuiltinExchangeType.DIRECT);
        //////////////////////////////////
        //声明队列

        Map<String,Object>arguments = new HashMap<>();
        //过期时间，一般在发送端设置
        //arguments.put("x-dead-message-ttl",10000);
        //设置死信交换机
        arguments.put("x-dead-letter-exchange",DEAD_EXCHANGE);
        //死信routingKey
        arguments.put("x-dead-letter-routing-key", "lisi");
        //设置队列最大长度限制
        arguments.put("x-max-length", 8);


        channel.queueDeclare(NORMAL_QUEUE, false, false, false, arguments);
        //////////////////////////////////
        //声明死信队列
        channel.queueDeclare(DEAD_QUEUE, false, false, false, null);
        //////////////////////////////////
        //帮忙交换机和队列
        channel.queueBind(NORMAL_QUEUE,NORMAL_EXCHANGE,"zhangsan");
        channel.queueBind(DEAD_QUEUE,DEAD_EXCHANGE,"lisi");
        System.out.println("等待接收消息...");
        //接收消息
        DeliverCallback deliverCallback = (consumerTag, message) -> {
            String msg = new String(message.getBody(), "UTF-8");
            if (msg.equals("info5")){
                //拒绝消息
                channel.basicReject(message.getEnvelope().getDeliveryTag(),false);
                System.out.println("Consumer01接收的消息是:" + msg +":被拒绝");
            }else {
                System.out.println("Consumer01接收的消息是:" + msg);
                channel.basicAck(message.getEnvelope().getDeliveryTag(),false);
            };

        };
        //开启手动应答
        channel.basicConsume(NORMAL_QUEUE, false, deliverCallback, consumerTag -> {
        });
    }
}

```

### C2：

```
package com.eric.rabbitmq.deadqueue;

import com.eric.rabbitmq.utils.RabbitMqUtils;
import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.DeliverCallback;

import java.util.HashMap;
import java.util.Map;

public class Consumer02 {
    public static final String DEAD_QUEUE = "dead_queue";


    public static void main(String[] args) throws Exception {
        //声明信道
        Channel channel = RabbitMqUtils.getChannel();
        System.out.println("等待接收消息...");
        //接收消息
        DeliverCallback deliverCallback = (consumerTag, message) -> {
            System.out.println("Consumer02接收的消息是:" + new String(message.getBody(), "UTF-8"));
        };
        channel.basicConsume(DEAD_QUEUE, true, deliverCallback, consumerTag -> {
        });
    }
}

```

