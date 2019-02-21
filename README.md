## mission12
# Mission12 - 理解Asynchronous架構，並追加sqs進入docker-compose設定檔之中



## 參考資料

**Async架構簡單描述**
https://codeblog.dotsandbrackets.com/asynchronous-communication-with-message-queue/

**SQS Docker版**
https://github.com/vsouza/docker-SQS-local

**SQS的Python語法**
https://boto3.amazonaws.com/v1/documentation/api/latest/guide/sqs.html

## 描述

簡單描述message queue的應用場景，並簡介sqs
在docker-compose.yml檔內追加一個sqs container
sqs的域名須為 cc104.sqs.local(container_name)(在docker-compose.yml做描述)
開啟一個sqs-example.ipynb，在裡面嘗試使用boto3套件連結至sqs進行 創建queue，丟message進入queue，從queue拉出message，刪除在queue裡的message

並將檔案上傳至github

## 相關技術

docker，docker-compose，sqs 


## SQS

**問：Amazon SQS 是否提供訊息排序？**
是。FIFO (先入先出) 佇列保留訊息傳送和接收的確切順序。如果您使用 FIFO 佇列，則不需要在訊息中放置序列資訊。如需詳細資訊，請參閱 *Amazon SQS Developer Guide* 中的 [FIFO Queue Logic](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues.html#FIFO-queues-understanding-logic)。
標準佇列提供鬆散的 FIFO 功能，以嘗試保留訊息順序。但是，由於標準佇列的設計可以透過高度分散式架構進行大幅度的擴展，因此無法保證接收訊息的順序會與訊息傳送的順序完全相同。


## python

野雞部落客參考資料
http://www.runoob.com/python/att-string-format.html

![](https://d2mxuefqeaa7sj.cloudfront.net/s_3198D62ACE316978B050F92677AA56A3682353B0C05D6F1E34A97F723BDB806B_1547107970407_image.png)

## 前景架構
    mkdir mission12
    vim docker-compose.yml
    vim dockerfile
    =========docker-compose.yml==================  注意docker-compose.yml格式
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
      sqs-local:
        image: vsouza/sqs-local
        container_name: cc104.sqs.local
        ports:
          - "9324:9324"
    =============================================
    ==========dockerfile=========================
    FROM jupyter/base-notebook
    RUN pip install PyMySQL
    RUN pip install boto3
    =============================================
    cd mission12
    ##執行在背景
    docker-compose up -d 
    =============================================

**開啟一個sqs-example.ipynb，在裡面嘗試使用boto3套件連結至sqs進行 創建queue**

    #引用套件
    import boto3
    #用boto3 套件與sqs作連結
    sqs = boto3.resource(
    
        'sqs',
    
        endpoint_url='http://cc104.sqs.local:9324',   #連線網址sqs.local(使用container_name) 
    
        region_name='dummy_region',                   #區域名稱 選用虛擬區域
    
        aws_access_key_id='dummy_access_key',         #aws進入鑰匙id選用虛擬進入key
    
        aws_secret_access_key='dummy_secret_key',     #aws私鑰選用虛擬私鑰進去
    
        verify=False) 

創建queue

    #創建一個queue，Queue名為test，屬性(延遲時間為5秒)
    queue = sqs.create_queue(QueueName='test', Attributes={'DelaySeconds': '5'})
    # You can now access identifiers and attributes
    print(queue.url)
    print(queue.attributes.get('DelaySeconds'))
    print("===============================")
    for queue in sqs.queues.all():
        print(1, queue.url)
![](https://d2mxuefqeaa7sj.cloudfront.net/s_3198D62ACE316978B050F92677AA56A3682353B0C05D6F1E34A97F723BDB806B_1547037631535_image.png)


**丟message進入queue**

    # Get the queue 名稱為 test
    queue = sqs.get_queue_by_name(QueueName='test')
    
    # Create a new message 創建訊息 內容為 apple
    response2 = queue.send_message(MessageBody='apple')
    
    # The response is NOT a resource, but gives you a message ID and MD5
    print(response2.get('MessageId'))
    print(response2.get('MD5OfMessageBody'))
    
    #==================================================
    #一次丟多個訊息進去queue
    response3 = queue.send_messages(Entries=[
        {
            'Id': '1',
            'MessageBody': 'world',
            'MessageAttributes': {
                'Author': {
                    'StringValue': 'Daniel1',
                    'DataType': 'String'
                }
            }
            
        },
        {
            'Id': '2',
            'MessageBody': 'boto3',
            'MessageAttributes': {
                'Author': {
                    'StringValue': 'Daniel2',
                    'DataType': 'String'
                }
            }
        }
    ])
    # Print out any failures
    print(response3.get('Failed'))
    
![](https://d2mxuefqeaa7sj.cloudfront.net/s_3198D62ACE316978B050F92677AA56A3682353B0C05D6F1E34A97F723BDB806B_1547037810568_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_3198D62ACE316978B050F92677AA56A3682353B0C05D6F1E34A97F723BDB806B_1547079963201_image.png)


從queue拉出message，並刪除在queue裡的message

    # Process messages by printing out body and optional(屬性名稱為"Author") author name
    #把message從queue 拉出來
    for message in queue.receive_messages(MessageAttributeNames=['Author']):
        # Get the custom author message attribute if it was set
        author_text = ''
        if message.message_attributes is not None:
            author_name = message.message_attributes.get('Author').get('StringValue')
            if author_name:
                author_text = ' ({0})'.format(author_name)
                print(author_text)
    
        # Print out the body and author (if set)
        print('Hello, {0}!{1}'.format(message.body, author_text))
        # Let the queue know that the message is processed
        message.delete()  #刪除message
![](https://d2mxuefqeaa7sj.cloudfront.net/s_3198D62ACE316978B050F92677AA56A3682353B0C05D6F1E34A97F723BDB806B_1547080259449_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_3198D62ACE316978B050F92677AA56A3682353B0C05D6F1E34A97F723BDB806B_1547080230154_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_3198D62ACE316978B050F92677AA56A3682353B0C05D6F1E34A97F723BDB806B_1547211550941_1.png)


message 一個一個處理，處理完後刪除。
