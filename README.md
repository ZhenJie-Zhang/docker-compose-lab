## mission11
# Mission11 - 將DynamoDB的docker環境整合至DockerCompose



## 參考資料

**dynamodb的 docker版本** 
https://hub.docker.com/r/amazon/dynamodb-local/

**dynamodb的 python調用語法**
https://boto3.amazonaws.com/v1/documentation/api/latest/guide/dynamodb.html

## 描述

在docker-compose.yml檔內追加一個dynamodb container

dynamodb的域名須為 cc104.dynamodb.local

jupyter 開啟時，已經自動安裝boto3套件

開啟一個dynamo-example.ipynb，在裡面嘗試使用boto3套件連結至dynamodb進行 創建資料庫，資料表，插入資料，查詢資料，刪除資料

並將檔案上傳至github

## 參考資料

https://boto3.amazonaws.com/v1/documentation/api/latest/guide/dynamodb.html
https://www.jianshu.com/p/69a30b9e496a

https://stackoverflow.com/questions/38379091/connect-to-dynamodb-local-from-inside-docker-container-with-boto3

## 相關資料

Amazon DynamoDB 是一種鍵值和文件資料庫，可在任何規模下達到不到 10 毫秒的效能。它是全受管、多區域、多主機的資料庫，內建安全性、備份和還原以及記憶體內快取，以供網際網路規模的應用程式使用。DynamoDB 每天可以處理超過 10 兆個請求，而且每秒最多可支援超過 2,000 萬個請求。

## 相關技術

docker 

docker-compose

python

boto3


----------

先複製mission10 資料夾的內容 到 mission11資料夾

    cp -r mission10 mission11 #copy
    cd mission11    #進入mission11資料夾
    #先pull dynamodb的 image 到本地
    docker pull amazon/dynamodb-local
    #在docker-compose.yml檔內追加一個dynamodb container.
    vim docker-compose.yml
    -------------------------
    ###docker-compose.yml
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
     --------------------------------------------------
     ###dockerfile
    FROM jupyter/base-notebook
    RUN pip install PyMySQL
    RUN pip install boto3
    
    
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546576303682_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546611663367_image.png)



探訪 192.168.254.100:8888
測試 boto3 是否創建成功


![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546611563704_image.png)


試使用boto3套件連結至dynamodb進行 創建資料庫，資料表，插入資料，查詢資料，刪除資料
step 1

    #連線 dynamodb 
    #引用套件
    import boto3
    
    dynamodb = boto3.resource(
    
        'dynamodb',
    
        endpoint_url='http://cc104.dynamodb.local:8000',   #連線網址192.168.254.100:8000 虛機ip位址，在虛機內開8
    
        region_name='dummy_region',                   #區域名稱 選用虛擬區域
    
        aws_access_key_id='dummy_access_key',         #aws進入鑰匙id選用虛擬進入key
    
        aws_secret_access_key='dummy_secret_key',     #aws私鑰選用虛擬私鑰進去
    
        verify=False)                                 #是否去认证ssl证书，默认SSL证书需要认证，設定verify=False不去认证SSL证书的有效性

step 2

    #創建資料表
    import boto3
    #創建table
    create_table = dynamodb.create_table(
        TableName='cc104',
           KeySchema=[
            {
                'AttributeName': 'username',
                'KeyType': 'HASH'   #主key
            },
            {
                'AttributeName': 'last_name',
                'KeyType': 'RANGE' #sortkey
            }
        ],
        AttributeDefinitions=[
            {
                'AttributeName': 'username',
                'AttributeType': 'S'
            },
            {
                'AttributeName': 'last_name',
                'AttributeType': 'S'
            },
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 50,
            'WriteCapacityUnits': 50
        }
    )
    #等待binghongtable 創建好 
    create_table.meta.client.get_waiter('table_exists').wait(TableName='cc104')
    
    # 計算cc104 table的物件數
    
    print(create_table.item_count)
## Tips
| ProvisionedThroughput: ReadCapacityUnits  | 在 DynamoDB 平衡此操作與其他操作的負載之前，為指定的資料表設定每秒使用的最小一致 `ReadCapacityUnits` 數。<br>「最終一致讀取」操作需要的工作量少於一致性讀取操作，因此設定每秒 50 個一致 `ReadCapacityUnits` 會提供每秒 100 個最終一致 `ReadCapacityUnits`。<br>類型：數字 | 是 |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | - |
| ProvisionedThroughput: WriteCapacityUnits | 在 DynamoDB 平衡此操作與其他操作的負載之前，為指定的資料表設定每秒使用的最小 `WriteCapacityUnits` 數。<br>類型：數字                                                                                                      | 是 |



![print(create_table.item_count)](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546783427727_image.png)


step3

    #引用套件
    import boto3
    #插入資料
    dynamodb2 = boto3.resource(
    
        'dynamodb',
    
        endpoint_url='http://192.168.254.100:8000',   #連線網址192.168.254.100:8000 虛機ip位址，在虛機內開8
    
        region_name='dummy_region',                   #區域名稱 選用虛擬區域
    
        aws_access_key_id='dummy_access_key',         #aws進入鑰匙id選用虛擬進入key
    
        aws_secret_access_key='dummy_secret_key',     #aws私鑰選用虛擬私鑰進去
    
        verify=False)    
    table = dynamodb2.Table('cc104')
    
    print('beforeput:', table.item_count)
    #插入資料
    table.put_item(
         Item={
            'username': 'apple',
            'last_name': 'banana',
            'age': 30,
            'account_type': 'standard_user'
             }
                )
    
    print('afterput:', table.item_count)
    
![before/after put](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546783482657_image.png)


step4

    #引用套件
    import boto3
    #查詢資料
    reeponse = table.get_item(
            Key={
                'username': 'apple',
                'last_name': 'banana'
            }
    )
    item = reeponse['Item']
    print(item)


![print(item)](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546783545836_image.png)


step5

    #引用套件
    import boto3
    #更新物件  
    table.update_item(
         Key={
            'username': 'apple',
            'last_name': 'banana'
         },
         UpdateExpression='SET age = :val1',  #更新表達式
    
         ExpressionAttributeValues={          #表達式屬性值
    
            ':val1': 60
        }
                )
![print(item)](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546784068178_image.png)


step6

    #引用套件
    import boto3
    #刪除資料
    print('beforedelete:', table.item_count)
    table.delete_item(
        Key={
            'username': 'apple',
            'last_name': 'banana'
        }
    )
    print('afterdelete:', table.item_count)
![table.item_count](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546784354844_image.png)
