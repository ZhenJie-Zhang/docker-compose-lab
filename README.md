# This project is my homework (mission)
## master------ > mission9
use  dockerfile  and dockercompose-yml to make docker container : jupyter and mariaDB
# Mission9 - DockerCompose製作開發環境

## 描述

使用DockerCompose，製作一個具有jupyter 與 mariaDB 兩個Container的環境，
並指定 jupyter的源碼資料夾保存位置 與 mariaDB的資料保存位置 回本地端

jupyter環境需奠基在dockerfile之上

使用gitignore技術，將mariaDB的資料忽略
其餘的上傳至github 

## 相關技術:

docker ,docker-compose,github
創建資料夾 mission9
以及下面的資料夾

    mkdir mission9
    cd mission9
    mkdir work
    mkdir -p ./mariadb/data
![](https://d2mxuefqeaa7sj.cloudfront.net/s_96F7A3FB34DB89E2122974FB08641B8148BEA2AB7310387C95ACA8D0F01121F3_1546508233395_image.png)


創建檔案 docker-compose.yml 和 dockerfile

    #dockerfile
    FROM jupyter/base-notebook
    RUN pip install PyMySQL
    
    #docker-compose.yml
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
      mariadb:
        image: mariadb
        container_name: mariadb.lab
        ports:
          - "3306:3306"
        volumes:
          - ./mariadb/data:/data/db/
        environment:
          MYSQL_ROOT_PASSWORD: iii
      adminer:
        image: adminer
        restart: always
        ports:
          - "8070:8070"
          

進入 mission9資料夾
執行docker-compose up 

    docker-compose up -d # 在背景執行
    docker-compose ps #檢視狀態
![](https://d2mxuefqeaa7sj.cloudfront.net/s_96F7A3FB34DB89E2122974FB08641B8148BEA2AB7310387C95ACA8D0F01121F3_1546492948424_image.png)

## 測試jupyter notebook
![](https://d2mxuefqeaa7sj.cloudfront.net/s_96F7A3FB34DB89E2122974FB08641B8148BEA2AB7310387C95ACA8D0F01121F3_1546508643309_image.png)



    docker-compose down  #關閉docker-compose down

## mission10
# Mission10 - 在jupyter上自動追加套件



## 描述

jupyter 開啟時，已經自動安裝PyMySQL套件

開啟一個rds-example.ipynb，並嘗試使用PyMySQL套件連結至mysql進行 創建資料庫，資料表，插入資料，查詢資料
並將檔案上傳至github

## 相關技術

docker docker-compose github pyt
參考文件
創建連結https://hk.saowen.com/a/1c2fa8c1eaf78defd154bfd50fd74a3688fa8fa1ca14af497ad99afd54693688
創建表單

http://www.codedata.com.tw/database/mysql-tutorial-9-table-index/


創建mission10資料夾並進入mission10資料夾

    mkdir mission10
    cd mission10/

創建 docker-compose.yml 和 dockerfile 以及 work 資料夾 mysql/data 等等資料夾 供 container 使用。

    cd mission10/
    #創建work/ mysql/data 資料夾 
    mkdir -p work/ ./mysql/data  
    #如果work/ 資料夾的權限o+w的話，使用瀏覽器訪問jupyter notebook時，在jupyter notebook 的work/將不能新增腳本
    ##創建 docker-compose.yml 和 dockerfile
    vim dockerfile
    vim docker-compose.yml
    ##創建.gitignore 隱藏檔設定不要.checkpoint 相關檔案，以及 mysql/data 資料夾的檔案上傳到git hub
    echo ".checkpoint" > .gitignore
    echo "mysql/data" >> .gitignore
    #建立撰寫docker-compose.yml 和 dockerfile
    vim docker-compose.ymld
    vim dockerfile
    
![docker-compose.yml](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546563419100_image.png)
![dockerfile](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546563450024_image.png)

![.gitignore](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546563885621_image.png)


執行docker-compose  以及查看container狀況

    #執行docker-compose 在背景
    docker-compose up -d
    #查看container狀況
    docker-compose ps
    
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546564971265_image.png)


造訪 jupyter notebook

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546565184385_image.png)


創建新的python3腳本，命名為rds-example

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546565582218_ju.png)


測試是否有預先安裝PyMysql套件

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546566069524_image.png)


到mysql.lab container 裡面逛逛 進入 mysql裡
登入 root 帳號 密碼 iii

    cd mission10
    #進去container
    docker container exec -it mysql.lab /bin/bash
    #登入進入 mysql
    mysql -u root -p
    密碼 ： iii
    #觀看有的資料庫
    mysql> show databases;
    #選用mysql資料庫
    mysql> use mysql
    
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546566391708_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546568336221_image.png)


回到jupyter notebook rds-example 腳本
連接資料庫
創建資料庫，資料表，插入資料，查詢資料

    #導入pymysql套件
    import pymysql
    # 連接database
    conn = pymysql.connect(host="cc104.mysql.local", user="root",password="iii",database="mysql",charset="utf8")
    # 得到一個可以執行SQL語句的光標對象
    cursor = conn.cursor()
    # 定義要執行的SQL語句
    #創建TABLE 名為USER
    #TABLE內容有id欄(自行產生)，name欄(長度限制為10字元，不可空),
    #age欄(从 0 到 255 的整型数据。存储大小为 1 字节，不可空<人應該不會超過255歲吧 ?)。
    sql = """
    CREATE TABLE USER (
    id INT auto_increment PRIMARY KEY ,
    name CHAR(10) NOT NULL UNIQUE,
    age TINYINT NOT NULL
    )ENGINE=innodb DEFAULT CHARSET=utf8;
    """
    #ENGINE=innodb DEFAULT CHARSET=utf8
    #查詢mysql支援的儲存引擎用 InnoDB 其支援transactions 
    # 執行SQL語句
    cursor.execute(sql)
    # 關閉對象
    cursor.close()
    # 關閉資料庫連接
    conn.close()
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546571458603_image.png)


插入資料

    #插入資料
    # 引入pymysql套件
    import pymysql
    # 連接database
    conn = pymysql.connect(host="cc104.mysql.local", user="root",password="iii",database="mysql",charset="utf8")
    # 得到一個可以執行SQL語句的對象
    cursor = conn.cursor()
    sql = "INSERT INTO USER(name, age) VALUES (%s, %s);"
    name = "Guanyebo"
    age = 23
    # 執行SQL語句
    cursor.execute(sql, [name, age])
    # 提交事務
    conn.commit()
    cursor.close()
    conn.close()
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546571435398_image.png)


查詢資料

    #查詢資料
    # 引入pymysql套件
    import pymysql
    # 連接database
    conn = pymysql.connect(host="cc104.mysql.local", user="root",password="iii",database="mysql",charset="utf8")
    # 得到一個可以執行SQL語句的對象
    cur = conn.cursor()
    #1.查詢操作  
    # 編寫sql 查詢語句  user 對應我的TABLE名  
    sql = "SELECT * FROM USER"
    try:  
        cur.execute(sql)    #執行sql語句  
      
        results = cur.fetchall()    #獲取查詢的所有記錄  
        print("id","name","age")  
        #遍歷結果  
        for row in results :  
            id = row[0]  
            name = row[1]  
            age = row[2]  
            print(id,name,age)  
    except Exception as e:  
        raise e  
    finally:  
        conn.close()  #關閉連接 
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546571195720_image.png)


關閉 dcker-compose

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546571604926_image.png)


push 到 git

    #先git clone
    git clone https://github.com/guan840912/lab2.git                                
    cd lab2/                                                                 
    git add mission10/                                                       
    git commit -m "mission10"                                                
    git push origin master  
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546572286110_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B876B3000AB1140044FEE738A95940A731180601AACDD10A56A38FB7A45D2025_1546572315112_image.png)
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

    git status   #查看 目前狀態
    git add mission11/
    git status
    git reset HEAD mission11
    git status
    git add mission11/
    git status
    git commit -m "mission11"
    git status
    git remote -v
    git push origin master
    
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546786935895_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546786969385_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1546786996723_image.png)

## mission12
