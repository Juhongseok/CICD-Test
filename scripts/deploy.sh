#!/usr/bin/env bash

REPOSITORY=/home/ubuntu/code
PROJECT_NAME=spring-cicd
JAR_NAME=$(ls -tr $REPOSITORY/ | grep 'SNAPSHOT.jar' | tail -n 1)
JAR_PATH=$REPOSITORY/build/libs/$JAR_NAME

cd $REPOSITORY

CURRENT_PID=$(pgrep -f $PROJECT_NAME.*.jar)

if [ -z $CURRENT_PID ]
then
  echo "> 종료할 애플리케이션이 없습니다"
else
  echo "> kill -15 $CURRENT_PID"
  kill -15 $CURRENT_PID
  sleep 5
fi

echo "> Deploy - $JAR_PATH"
sudo nohup java -jar $JAR_PATH &
