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

yum install kibana -y &>>$LOGFILE
VALIDATE $? "kibana Installation"

sudo sed -i 's/#server.port: 5601/server.port: 5601/' /etc/kibana/kibana.yml &>> $LOGFILE
VALIDATE $? "replaced server.port: 5601"

sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml &>> $LOGFILE
VALIDATE $? "replaced server.host: "0.0.0.0""


sudo sed -i 's|#elasticsearch.hosts: \["http://localhost:9200"\]|elasticsearch.hosts: ["http://localhost:9200"]|' /etc/kibana/kibana.yml &>> $LOGFILE
#sudo sed -i 's/#elasticsearch.hosts: ["http://localhost:9200"]/elasticsearch.hosts: ["http://localhost:9200"]/' /etc/kibana/kibana.yml &>> $LOGFILE
VALIDATE $? "uncomment elasticsearch.hosts: ["http://localhost:9200"]"

sudo systemctl restart kibana &>>$LOGFILE
VALIDATE $? "restart kibana"

sudo systemctl enable kibana &>>$LOGFILE
VALIDATE $? "enable kibana"

sudo systemctl status kibana &>>$LOGFILE
VALIDATE $? "kibana status"