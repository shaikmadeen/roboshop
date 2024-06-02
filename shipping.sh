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

dnf install maven -y &>> $LOGFILE

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping"

cd /app

VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "renaming jar file"

cp /home/centos/roboshop/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "copying shipping service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "deamon reload"

systemctl enable shipping  &>> $LOGFILE

VALIDATE $? "enable shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "start shipping"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "install MySQL client"

mysql -h 10.0.1.229 -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "restart shipping"