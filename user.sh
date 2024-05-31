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

VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:18 -y  &>> $LOGFILE

VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y  &>> $LOGFILE

VALIDATE $? "Installing NodeJS:18"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  &>> $LOGFILE

VALIDATE $? "Downloading user application"

cd /app 

unzip -o /tmp/user.zip  &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install  &>> $LOGFILE

VALIDATE $? "Installing dependencies"

# use absolute, because catalogue.service exists there
cp /home/centos/roboshop/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host mongodb.devops.online </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into MongoDB"