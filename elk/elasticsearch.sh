#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

yum install java-11-openjdk-devel -y  &>>$LOGFILE
VALIDATE $? "Java 11 Installation"

echo "
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
" > /etc/yum.repos.d/elasticsearch.repo

yum install elasticsearch -y &>>$LOGFILE
VALIDATE $? "elasticsearch Installation"

sed -i 's/#http.port: 9200/http.port: 9200/' /etc/elasticsearch/elasticsearch.yml &>> $LOGFILE
VALIDATE $? "replaced http.port: 9200"

sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml &>> $LOGFILE
VALIDATE $? "replaced network.host: 0.0.0.0"

sed -i '/^#discovery/ a discovery.type: single-node' /etc/elasticsearch/elasticsearch.yml &>> $LOGFILE
VALIDATE $? "adding discovery.type: single-node"

systemctl restart elasticsearch &>>$LOGFILE
VALIDATE $? "elasticsearch restarting service"

systemctl enable elasticsearch &>>$LOGFILE
VALIDATE $? "elasticsearch enable service"


systemctl status elasticsearch &>>$LOGFILE
VALIDATE $? "elasticsearch status"