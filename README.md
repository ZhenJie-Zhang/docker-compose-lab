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
