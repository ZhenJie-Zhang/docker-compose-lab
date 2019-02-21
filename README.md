## mission18
# Mission18 - 追加SNS至docker-compose環境中(請直接跳到正文開始看)

## 參考資料

https://kevinholditch.co.uk/2017/10/19/running-sns-sqs-locally-in-docker-containers-supporting-fan-out/


## 萬惡的boto3

https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sns.html


----------
https://aws.amazon.com/tw/blogs/compute/simplify-pubsub-messaging-with-amazon-sns-message-filtering/

----------
https://aws.amazon.com/cn/blogs/developer/subscribing-an-sqs-queue-to-an-sns-topic/

## 描述


追加aws sns docker，並使sns能夠 與 環境中的sqs 進行串接

sns 可以發消息 進入sqs

另外可用Python對sns進行topic 創建 新增內容推送


## 相關技術
https://aws.amazon.com/tw/blogs/compute/simplify-pubsub-messaging-with-amazon-sns-message-filtering/


Tips

    sns是分布式发布-订阅系统，一旦publisher发布了，subscriber那边立刻能接收到。
    sns的订阅者（end point）可以是邮件，sms，甚至是sqs，通常用于subscriber数量未知的情况
    sqs是分布式的队列系统，message不默认推送到subscriber那里。
    subscriber得到message需要轮询（polling）。
    一旦某个subscriber接收、处理或者删除这个message，其他的订阅者就不会收到同样的message了
## awscli碼
    aws sns publish --topic-arn arn:aws:sns:us-east-1:1465414804035:test1 --endpoint-url http://cc104.sns.local:9911 --message "hello bing hong eat chicken leg ~~~~~   oh~~~~"
    
    aws sqs receive-message --queue-url http://local:9324/queue/queue1 --region elasticmq --endpoint-url http://cc104.sqs.local:9324 --no-verify-ssl --no-sign-request --attribute-names All --message-attribute-names All


問題探討: sqs 沒有真正訂閱到 新增的topic : cc104
導致於 publish 沒有成功。


----------
## 實驗環境
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547376534331_image.png)


docker-compose.yml 內容

    version: '3'
    services:
      jupyter-tutorial:
        build: .
        container_name: jupyter.local
        ports:
          - "8888:8888"
          - "5000:5000"
        volumes:
          - ./work:/home/jovyan/work/
        command: start-notebook.sh --NotebookApp.token=''
      mysql:
        image: mysql:5.7
        container_name: cc104.mysql.local
        ports:
          - "3306:3306"
        volumes:
          - ./mysql/data:/data/db/
        environment:
          - MYSQL_ROOT_PASSWORD=iii
      dynamodb:
        image: amazon/dynamodb-local
        container_name: cc104.dynamodb.local
        ports:
          - "8000:8000"
      s3-local:
        image: gliffy/fake-s3
        container_name: cc104.s3.local
        ports:
          - "4569:4569"
      sns:
        image: s12v/sns
        container_name: cc104.sns.local
        ports:
        - "9911:9911"
        volumes:
        - ./config/db.json:/etc/sns/db.json
        depends_on:
        - sqs
        - jupyter-tutorial
      sqs:
        image: s12v/elasticmq
        container_name: cc104.sqs.local
        ports:
        - "9324:9324"
        volumes:
        - ./config/elasticmq.conf:/etc/elasticmq/elasticmq.conf
        depends_on:
        - jupyter-tutorial
    

dockerfile內容

    FROM jupyter/base-notebook
    RUN pip install PyMySQL
    RUN pip install boto3
    RUN pip install awscli
## 開始實驗

實驗流程:
先創建一個sns topic 名為 cc104_test →在SQS中創建一個新的queue 名為 cc104test
→使test queue 訂閱 cc104_test主題 → publish message 到 cc104_test主題→
cc104test queue  將會收到message。
連線 sns

    import boto3
    sns = boto3.client('sns', 
    endpoint_url='http://cc104.sns.local:9911',   
        region_name='dummy_region',
        aws_access_key_id='dummy_access_key',         
        aws_secret_access_key='dummy_secret_key',     
        verify=False)  

create topic 名為 cc104_test

    create_sns = sns.create_topic(
        Name='cc104_test',
        Attributes={    'Key': 'labs'   })
    print(create_sns)
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547631171494_image.png)


查看一下現有的主題

- sns.list_topics()
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547631218443_image.png)

    創建一個 cc104test的queue
    import boto3
    sqs = boto3.resource('sqs', 
    endpoint_url='http://cc104.sqs.local:9324',   
        region_name='dummy_region',
        aws_access_key_id='dummy_access_key',         
        aws_secret_access_key='dummy_secret_key',     
        verify=False) 
    #創建一個queue，Queue名為test，屬性(延遲時間為5秒)
    queue = sqs.create_queue(QueueName='cc104test', Attributes={'DelaySeconds': '5'})
    # You can now access identifiers and attributes
    print(queue.url)


![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547637614576_image.png)

    使cc104test queue 訂閱 cc104_test主題
    response = sns.subscribe(
        TopicArn='arn:aws:sns:us-east-1:123456789012:cc104_test',
        Protocol='sqs',
        Endpoint="aws-sqs://cc104test?amazonSQSEndpoint=http://cc104.sqs.local:9324&accessKey=&secretKey=",
        Attributes={'string':'event_type'},
        ReturnSubscriptionArn=True
    )
    print(response)
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547631356839_image.png)

- 查看訂閱列表
    print(sns.list_subscriptions())
    print(sns.list_subscriptions().get('Subscriptions')[4])
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547637525480_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547690917248_image.png)


publish message 到 cc104_test主題

    sns.publish(
        TopicArn ='arn:aws:sns:us-east-1:123456789012:cc104_test',
        Subject = 'sns_test',
        Message ="{'Message':'bang bang bang!!! ~~'}",
        MessageAttributes = {
            'event_type': {
                'DataType': 'String',
                'StringValue': 'product_page_visited'}})
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547632803219_image.png)


test queue  將會收到message

    # Get the queue 名稱為 test# Get the queue 名稱為 test
    queue = sqs.get_queue_by_name(QueueName='cc104test')
    import json
    for d in queue.receive_messages():
        bing = json.loads(d.body)
        print(bing['Message'])
        d.delete()
    print("print comolete")
    
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547634665852_image.png)


TRY ANGIN

    sns.publish(
        TopicArn ='arn:aws:sns:us-east-1:123456789012:cc104_test',
        Subject = 'sns_test',
        Message ="Hero or Zero , bind hong ?! ",
        MessageAttributes = {
            'event_type': {
                'DataType': 'String',
                'StringValue': 'product_page_visited'
            }
        }
    )
    ------------------------------------------------------------------
    import json
    for d in queue.receive_messages():
        bing = json.loads(d.body)
        print(bing['Message'])
        d.delete()
    print("print comolete")
    
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4C0F5865364EC99DF9FEE5BD584453B108B328D32C7E02F2DF230CF3799C7FB5_1547637379374_image.png)

## mission19
# Mission19 - 追加Redis至docker-compose環境中

## 參考資料

https://hub.docker.com/_/redis

## 描述

查詢AWS ElasticCache 支援的Redis版本號，並選擇相應的Redis版本號docker，添加至docker compose中

並在jupyter的dockerfile中，追加redis的python官方套件，並連結redis進行資料存取

## 相關技術


# How to use this image
## start a redis instance
    $ docker run --name some-redis -d redis

This image includes `EXPOSE 6379` (the redis port), so standard container linking will make it automatically available to the linked containers (as the following examples illustrate).

## start with persistent storage
    $ docker run --name some-redis -d redis redis-server --appendonly yes

If persistence is enabled, data is stored in the `VOLUME /data`, which can be used with `--volumes-from some-volume-container` or `-v /docker/host/dir:/data` (see [docs.docker volumes](https://docs.docker.com/engine/tutorials/dockervolumes/)).
For more about Redis Persistence, see [http://redis.io/topics/persistence](http://redis.io/topics/persistence).


## 實驗環境
![](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547645305529_image.png)

    docker-compose.yml
    ============================================================
    version: '3'
    services:
      jupyter-tutorial:
        build: .
        container_name: jupyter.local
        ports:
          - "8888:8888"
          - "5000:5000"
        volumes:
          - ./work:/home/jovyan/work/
        command: start-notebook.sh --NotebookApp.token=''
      mysql:
        image: mysql:5.7
        container_name: cc104.mysql.local
        ports:
          - "3306:3306"
        volumes:
          - ./mysql/data:/data/db/
        environment:
          - MYSQL_ROOT_PASSWORD=iii
      dynamodb:
        image: amazon/dynamodb-local
        container_name: cc104.dynamodb.local
        ports:
          - "8000:8000"
      s3-local:
        image: gliffy/fake-s3
        container_name: cc104.s3.local
        ports:
          - "4569:4569"
      sns:
        image: s12v/sns
        container_name: cc104.sns.local
        ports:
        - "9911:9911"
        volumes:
        - ./config/db.json:/etc/sns/db.json
        depends_on:
        - sqs-local
        - jupyter-tutorial
      sqs:
        image: s12v/elasticmq
        container_name: cc104.sqs.local
        ports:
        - "9324:9324"
        volumes:
        - ./config/elasticmq.conf:/etc/elasticmq/elasticmq.conf
        depends_on:
        - jupyter-tutorial
      redis:
        image: redis:5.0
        container_name: cc104.redis.local
        ports:
        - "6379:6379"
        command: redis-server --requirepass "iii" --appendonly "yes"
    ============================================================
    dockerfile
    ============================================================
    FROM jupyter/base-notebook
    RUN pip install PyMySQL
    RUN pip install boto3
    RUN pip install awscli
    RUN pip install redis
    ============================================================

**啟用redis 服務**
**並連結redis進行資料存取**

    #連線redis container , password is "iii"  
    import redis
    try:
        conn = redis.StrictRedis(
            host='cc104.redis.local',
            port="6379",
            password='iii')
        print(conn)
        conn.ping()
        print('Connected!')
    except Exception as ex:
        print ('Error:'), ex
        #exit('Failed to connect, terminating.')
![](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547711429749_image.png)


查看創建，查詢，上傳，刪除紀錄。

    #Creating, Reading, Updating and Deleting Records
    import redis
    try:
        conn2 = redis.StrictRedis(
            host='cc104.redis.local',
            port="6379",
            password='iii',
            ssl=False)
        print ('Set Record:', conn2.set("best_car_ever", "Tesla Model S"))
        print ('Get Record:', conn2.get("best_car_ever"))
        print ('Delete Record:', conn2.delete("best_car_ever"))
        print ('Get Deleted Record:', conn2.get("best_car_ever"))
    except Exception as ex:
        print ('Error:'), ex
![](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547711445138_image.png)


創建新的key = id 與 value = binghong 

    #創建新的key
    conn.set("id","binghong")
![](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547711465712_image.png)

    #取得key 的 value 值
    conn.get("id")
![](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547711536027_image.png)

    #查詢key是否存在
    print(conn.exists("id"))     #存在為1
    print(conn.exists("id2"))    #不存在為0
![](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547711886191_image.png)

    #查詢所有存在的key
    conn.keys("*")
![](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547712246476_image.png)

    #刪除已存在的key
    conn.delete("id")
![回復1表示已刪除](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547712688597_image.png)

    #再次查詢所有存在的key
    conn.keys("*")
![刪除前](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547712246476_image.png)

![刪除後](https://d2mxuefqeaa7sj.cloudfront.net/s_F041A394665C014083E0D8A308AB168DEEE7E6E96196625E2F53A3CC168A548D_1547712744472_image.png)


**redis 的實際應用**
**Cache Python MySQL Result using Redis**

> We’re often using MySQL so much, like read data from DB, calculate something, write data with index. And I bet You know, that process is also using your i/o machine. I prefer my CPU usage 100% than my i/o 50%.

[Redis](http://redis.io/) is live in memory, so it won’t do anything like read / write to disk that make your i/o process high (untill your max memory, if it’s not enough, redis create virtual memory, CMIIW). I plan to make my application faster and faster with caching using redis, and I will improve my [news web crawler](https://clasense4.wordpress.com/2012/07/25/improvement-news-web-crawler-combine-with-redis/) to going faster with redis as cache.

### 相關應用 點擊率，排行榜，資料的快取。
