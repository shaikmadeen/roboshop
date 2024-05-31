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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "Installing remi release"

dnf module enable redis:remi-6.2 -y  &>> $LOGFILE

VALIDATE $? "Enabling redis"
 
dnf install redis -y  &>> $LOGFILE

VALIDATE $? "Installing redis" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE

VALIDATE "allowing remote connections"

systemctl enable redis  &>> $LOGFILE

VALIDATE $? "Enabling redis"

systemctl start redis  &>> $LOGFILE

VALIDATE $? "Starting redis"