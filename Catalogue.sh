#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? " Rpm installed" 
yum install nodejs -y &>>$LOGFILE
VALIDATE $? "yum install"
useradd roboshop 
mkdir /app
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "downloading"
cd /app &>>$LOGFILE

unzip /tmp/catalogue.zip &>>$LOGFILE
VALIDATE $? "unzip"
npm install &>>$LOGFILE
VALIDATE $? "npm package downaload"
cp /home/centos/sriv/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "catalogue.service"
systemctl daemon-reload &>>$LOGFILE
VALIDATE $? " demon-load"
systemctl enable catalogue &>>$LOGFILE
VALIDATE $? " enable"
systemctl start catalogue &>>$LOGFILE
VALIDATE $? " start"
cp /home/centos/sriv/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "installed client"
mongo --host mongodb.srivijay.online </app/schema/catalogue.js &>>$LOGFILE
