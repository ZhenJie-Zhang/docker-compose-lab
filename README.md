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

## mission11
