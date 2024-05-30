#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/home/centos/shellscript-logs
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"


if [ $USERID -ne 0 ]
then
   echo -e "$R ERROR:: please run this script with root access $N"
   exit 1
fi 

VALIDATE(){
    if [ $1 -ne 0 ];
    then 
       echo -e "Installing $2 ... $R FAILURE $N"
       exit 1
    else
       echo -e "Installing $2 ... $G SUCCESS $N"
    fi
 }

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs"

# once the user is created, if you run the script second time
# this command will defnitely fail
# improvement: first check the user exists or not, if not exist then create
useradd roboshop &>> $LOGFILE

# write a condition to check directory already exist or not
mkdir /app &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downoading catalogue artifact"

cd /app &>> $LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

# give full path of catalogue.service because we are inside app
cp /home/centos/roboshop/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copiying catalogue.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongo client"

mongo --host mongodb.devops.online </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into monngodb"




