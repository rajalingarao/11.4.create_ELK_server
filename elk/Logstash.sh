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

# sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch &>>$LOGFILE
# VALIDATE $? "elasticsearch GPG-KEY"

# echo "
# [logstash-8.x]
# name=Elastic repository for 8.x packages
# baseurl=https://artifacts.elastic.co/packages/8.x/yum
# gpgcheck=1
# gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
# enabled=1
# autorefresh=1
# type=rpm-md
#  " > /etc/yum.repos.d/logstash.repo


echo "
[logstash-9.x]
name=Elastic repository for 9.x packages
baseurl=https://artifacts.elastic.co/packages/9.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
 " > /etc/yum.repos.d/logstash.repo

yum install logstash -y &>>$LOGFILE
VALIDATE $? "logstash Installation"

# echo "
# input {
#   beats {
#     port => 5044
#   }
# }
# filter {
#       grok {
#         match => { "message" => "%{IP:client_ip} \[%{HTTPDATE:timestamp}\] %{WORD:http_method} %{URIPATH:request_path} %{NOTSPACE:http_version} %{NUMBER:status:int} %{NUMBER:response_size:int} \"%{URI:referrer}\" %{NUMBER:response_time:float}" }
#       }
# }
# output {
#   elasticsearch {
#     hosts => ["http://localhost:9200"]
#     index => "%{[@metadata][beat]}-%{[@metadata][version]}"
#   }
# }" > /etc/logstash/conf.d/logstash.conf &>>$LOGFILE
# VALIDATE $? "Configure logstash input and output"

sudo tee /etc/logstash/conf.d/logstash.conf > /dev/null <<EOF
input {
  beats {
    port => 5044
  }
}
filter {
  grok {
    match => { "message" => "%{IP:client_ip} \[%{HTTPDATE:timestamp}\] %{WORD:http_method} %{URIPATH:request_path} %{NOTSPACE:http_version} %{NUMBER:status:int} %{NUMBER:response_size:int} \"%{URI:referrer}\" %{NUMBER:response_time:float}" }
  }
}
output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "%{[@metadata][beat]}-%{[@metadata][version]}"
  }
}
EOF
VALIDATE $? "Configure logstash input and output"

systemctl restart logstash &>>$LOGFILE
VALIDATE $? "restart logstash"

systemctl enable logstash &>>$LOGFILE
VALIDATE $? "enable logstash"

systemctl status logstash &>>$LOGFILE
VALIDATE $? "logstash status"