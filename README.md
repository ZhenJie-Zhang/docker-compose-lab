## mission13
# Mission13 - 追加s3進入docker-compose設定檔之中



## 參考資料


**S3 Docker版**
https://github.com/adobe/S3Mock

**S3的Python語法**
https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-examples.html


## 描述

在docker-compose.yml檔內追加一個s3 container

s3的域名須為 cc104.s3.local

開啟一個s3-example.ipynb，在裡面嘗試使用boto3套件連結至s3進行 創建bucket, put data into bucket, get data from bucket, delete data from bucket, list all bucket

並將檔案上傳至github

## 相關技術

docker，docker-compose，s3，python
docker 觀念 **4569:4569**

## 不讓credential 明碼秀出來
----------
    mkdir .aws/
    vim config
    [profile user1]
    region=dummy_region
    output=text
    vim credentials
    [user1]
    aws_access_key_id=dummy_access_key
    aws_secret_access_key=dummy_secret_key
    ---------------------------------------------------------------
    將 aws credentials 設定檔帶入 jupyter-notebook container 中
    
    
![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1548158899576_image.png)



    docker-compose.yml #更新部分 將.aws文件帶入 jupyter-notebook container 中
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
          - ./.aws:/home/jovyan/.aws/
        command: start-notebook.sh --NotebookApp.token=''
    .
    .
    .    
        

使用 session 功能去取用credential

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1548159282970_image.png)


籃子建立成功

![](https://d2mxuefqeaa7sj.cloudfront.net/s_B6AC650958C7504BF1B39AE73600B63B20533C976899C975DFF448A54F706938_1548159403150_image.png)


更新時間 2019.01.22





![](https://d2mxuefqeaa7sj.cloudfront.net/s_41B5E4F2DDFCE8C64D5EC21E230708AAD7E639D0A87DD41A003DC10FCBE92D10_1547167251644_image.png)

## 前景環境架構：docker-compose , dockerfile 

 

    mkdir mission13
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
      s3:
        image: gliffy/fake-s3
        container_name: cc104.s3.local
        ports:
          - "4569:4569"
    =============================================
    ==========dockerfile=========================
    FROM jupyter/base-notebook
    RUN pip install PyMySQL
    RUN pip install boto3
    =============================================
    cd mission13
    ##執行在背景
    docker-compose up -d 
    =============================================
## jupyter note  在work/ 下開啟一個s3-example.ipynb

**python - resource，client之間的boto3差異？**
https://code.i-harness.com/zh-CN/q/28d3708

  tips：**work/需o+w(可寫)**

1.嘗試使用boto3套件連結至s3

    #引用套件
    import boto3
    
    s3 = boto3.resource(
    
        's3',
    
        endpoint_url='http://cc104.s3.local:4569',    #連線containercc104.s3.local:9090
    
        region_name='dummy_region',                   #區域名稱 選用虛擬區域
    
        aws_access_key_id='dummy_access_key',         #aws進入鑰匙id選用虛擬進入key
    
        aws_secret_access_key='dummy_secret_key',     #aws私鑰選用虛擬私鑰進去
    
        verify=False)                                 #是否去认证ssl证书，默认SSL证书需要认证，設定verify=False不去认证SSL证书的有效性

2.創建bucket(創建籃子)

    #創建一個bucket in s3
    client.create_bucket(Bucket='my-bucket')
    =============================================
    response = client.list_buckets()
    buckets = [bucket['Name'] for bucket in response['Buckets']]
    
    print("Bucket List: %s" % buckets)
![create buckets output](https://d2mxuefqeaa7sj.cloudfront.net/s_41B5E4F2DDFCE8C64D5EC21E230708AAD7E639D0A87DD41A003DC10FCBE92D10_1547172638453_image.png)


3.put data into bucket(上傳)

    ============撰寫一個json格式的檔案==============
    import json
    import os
    data={
        "people":"binghong",
        "action":"eat chicken leg!!!",
        "where":"cc104"
    }
    
    writefile = open('binghong.txt','w')
    writefile.write(json.dumps(data))
    writefile.close()
    ===========上傳至s3 的 my_bucket 內==============
    # Uploads the given file using a managed uploader, which will split up large
    # files automatically and upload parts in parallel.
    s3.meta.client.upload_file('binghong.txt', 'my-bucket', 'binghong.txt') 
                              #(本地filename, s3 bucket_name, 在bucket內的filename)

4.get data from bucket(下載)

    import boto3
    import botocore
    s3 = boto3.resource('s3',
        endpoint_url='http://cc104.s3.local:4569',    #連線container:cc104.s3.local:9090
        region_name='dummy_region',                   #區域名稱 選用虛擬區域
        aws_access_key_id='dummy_access_key', 
        aws_secret_access_key='dummy_secret_key', 
        verify=False)
    
    try:
        s3.Bucket("my-bucket").download_file("binghong.txt", 'local_binghong.txt')
    except botocore.exceptions.ClientError as e:
        if e.response\['Error'\]['Code'] == "404":
            print("The object does not exist.")
        else:
            raise
![](https://d2mxuefqeaa7sj.cloudfront.net/s_41B5E4F2DDFCE8C64D5EC21E230708AAD7E639D0A87DD41A003DC10FCBE92D10_1547199122610_image.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_41B5E4F2DDFCE8C64D5EC21E230708AAD7E639D0A87DD41A003DC10FCBE92D10_1547199463593_image.png)


5.delete data from bucket(刪除)

    client.delete_object(Bucket='my-bucket',Key='binghong.txt')
![](https://d2mxuefqeaa7sj.cloudfront.net/s_41B5E4F2DDFCE8C64D5EC21E230708AAD7E639D0A87DD41A003DC10FCBE92D10_1547203227669_image.png)


6.list all bucket(列出籃子)

    pprint(client.list_buckets())  ##秀不出他的name
![](https://d2mxuefqeaa7sj.cloudfront.net/s_41B5E4F2DDFCE8C64D5EC21E230708AAD7E639D0A87DD41A003DC10FCBE92D10_1547203364732_image.png)


7.再次下載不存在(binghong.txt)

    import boto3
    import botocore
    s3 = boto3.resource('s3',
        endpoint_url='http://cc104.s3.local:4569',    #連線container:cc104.s3.local:9090
        region_name='dummy_region',                   #區域名稱 選用虛擬區域
        aws_access_key_id='dummy_access_key', 
        aws_secret_access_key='dummy_secret_key', 
        verify=False)
    
    try:
        s3.Bucket("my-bucket").download_file("binghong.txt", 'local_binghong.txt')
    except botocore.exceptions.ClientError as e:
        if e.response\['Error'\]['Code'] == "404":
            print("The object does not exist.")
        else:
            raise
![](https://d2mxuefqeaa7sj.cloudfront.net/s_41B5E4F2DDFCE8C64D5EC21E230708AAD7E639D0A87DD41A003DC10FCBE92D10_1547212924379_image.png)
