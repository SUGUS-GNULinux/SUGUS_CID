#!/bin/bash

function persistLogs {
    mkdir -p $DOCKERS_LOGS_PATH/$1

    ContainerId=`docker ps -qa --filter "name=$1"`
    if [ -n "$ContainerId" ]
    then
        CurrentDate=`date +%Y-%m-%d_%H:%M:%S`
        docker logs $1 >& $DOCKERS_LOGS_PATH/$1/$CurrentDate--$ContainerId-$1.log
    fi
}

function dockerStopAndRm {
    ContainerId=`docker ps -qa --filter "name=$1"`
    if [ -n "$ContainerId" ]
    then
        echo "Stopping and removing existing $1 container"
        docker stop $ContainerId
        persistLogs $1
        docker rm -v $ContainerId
    fi
}

function dockerTimeZoneGeneric {
    docker exec $1 \
    bash -c "echo "Europe/Madrid" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata"
}

dockerTimeZoneAlpine="apk add tzdata && cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime && echo 'Europe/Madrid' > /etc/timezone && apk del tzdata"

function persistPasswords {
    DOCKER_NAME=$1
    BRANCH=$2
    PASSWORD=$3
    FILE_PASSWORD=$4
    ContainerId=`docker ps -qa --filter "name=$DOCKER_NAME"`

    echo "$BRANCH - $DOCKER_NAME($ContainerId) => '$PASSWORD'" >> $FILE_PASSWORD
}
