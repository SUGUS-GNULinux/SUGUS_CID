#!/bin/bash

function dockerStopAndRm {
    ContainerId=`docker ps -qa --filter "name=$1"`
    if [ -n "$ContainerId" ]
    then
        echo "Stopping and removing existing $1 container"
        docker stop $ContainerId
        docker rm -v $ContainerId
    fi
}

function dockerTimeZoneGeneric {
    docker exec $1 \
    bash -c "echo "Europe/Madrid" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata"
}

function persistPasswords {
    DOCKER_NAME=$1
    BRANCH=$2
    PASSWORD=$3
    FILE_PASSWORD=$4
    ContainerId=`docker ps -qa --filter "name=$DOCKER_NAME"`

    echo "$BRANCH - $DOCKER_NAME($ContainerId) => '$PASSWORD'" >> $FILE_PASSWORD
}
