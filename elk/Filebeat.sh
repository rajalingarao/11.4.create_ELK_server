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

echo "
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
" >/etc/yum.repos.d/elasticsearch.repo
VALIDATE $? "adding repo for elasticsearch"

yum install filebeat -y &>>$LOGFILE
VALIDATE $? "filebeat Installation"

sudo sed -i 's/  enabled: false/  enabled: true/' /etc/filebeat/filebeat.yml &>>$LOGFILE
VALIDATE $? "Enabled filebeat module"

sudo sed -i 's|^[[:space:]]*- /var/log/\*\.log|  - /var/log/nginx/access.log|' /etc/filebeat/filebeat.yml &>>$LOGFILE
VALIDATE $? "replaced /var/log/nginx/access.log"

sed -i '/^\s*output.elasticsearch:/s/^/# /' /etc/filebeat/filebeat.yml &>>$LOGFILE
VALIDATE $? "comment output.elasticsearch"

sed -i '/^[[:space:]]*hosts: \["localhost:9200"\]/s/^/# /' /etc/filebeat/filebeat.yml &>>$LOGFILE
VALIDATE $? "comment   hosts: ["localhost:9200"]"

# Uncomment the output.logstash line
sed -i 's/^#output\.logstash:/output.logstash:/' /etc/filebeat/filebeat.yml &>>$LOGFILE
VALIDATE $? "replace output.logstash"

#uncomment and update latest
sudo sed -i 's/^[[:space:]]*#\?hosts: *\["localhost:5044"\]/  hosts: ["elastic-search.lithesh.shop:5044"]/' /etc/filebeat/filebeat.yml &>>$LOGFILE
VALIDATE $? "replaced elastic-search.lithesh.shop:5044"

systemctl restart filebeat &>>$LOGFILE
VALIDATE $? "start filebeat"

systemctl status filebeat &>>$LOGFILE
VALIDATE $? "filebeat status"








# #!/bin/bash

# USERID=$(id -u)
# TIMESTAMP=$(date +%F-%H-%M-%S)
# SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
# LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"

# VALIDATE(){
#    if [ $1 -ne 0 ]
#    then
#         echo -e "$2...$R FAILURE $N"
#         exit 1
#     else
#         echo -e "$2...$G SUCCESS $N"
#     fi
# }

# if [ $USERID -ne 0 ]
# then
#     echo "Please run this script with root access."
#     exit 1 # manually exit if error comes.
# else
#     echo "You are super user."
# fi

# echo "[elasticsearch]
# name=Elasticsearch repository for 7.x packages
# baseurl=https://artifacts.elastic.co/packages/7.x/yum
# gpgcheck=1
# gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
# enabled=1
# autorefresh=1
# type=rpm-md  " >/etc/yum.repos.d/elasticsearch.repo
# VALIDATE $? "adding repo for elasticsearch"

# yum install filebeat -y &>>$LOGFILE
# VALIDATE $? "filebeat Installation"

# sudo sed -i 's/  enabled: false/  enabled: true/' /etc/filebeat/filebeat.yml &>> $LOGFILE
# VALIDATE $? "Enabled filebeat module"

# sudo sed -i 's|^[[:space:]]*- /var/log/\*\.log|  - /var/log/nginx/access.log|' /etc/filebeat/filebeat.yml &>> $LOGFILE
# VALIDATE $? "replaced /var/log/nginx/access.log"

# sudo sed -i 's|^[[:space:]]*hosts: \["localhost:9200"\]|  hosts: ["http://elastic-search.lithesh.shop:9200"]|' /etc/filebeat/filebeat.yml &>> $LOGFILE
# VALIDATE $? "Replaced latest Elasticsearch IP address"

# systemctl restart filebeat &>>$LOGFILE
# VALIDATE $? "restart filebeat"

# systemctl status filebeat &>>$LOGFILE
# VALIDATE $? "filebeat status"
