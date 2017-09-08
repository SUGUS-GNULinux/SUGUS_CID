#!/bin/bash

CONFIG_ROOT="/home/core/SUGUS_CID"

## Include dependencies

source $CONFIG_ROOT/commonDependencies/DockerUtils.sh


## Defining variables

source $CONFIG_ROOT/commonDependencies/variables.sh

ENV_NAME="minolobot"
BRANCH="dev"


## Compiling source
echo "_____________ Generando build _____________"

COMPILE_FOLDER="$BUILD_FOLDER/$RANDOM_FOLDER_NAME"

mkdir -p "$COMPILE_FOLDER"

cp -r $REPO_PATH/$ENV_NAME-$BRANCH/* $COMPILE_FOLDER

## Copying vendor folder
cp -r "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/vendor" $COMPILE_FOLDER/vendor

docker run --rm \
    -v $COMPILE_FOLDER:/go/src/github.com/SUGUS-GNULinux/minolobot \
    -w /go/src/github.com/SUGUS-GNULinux/minolobot \
    dockerepo/glide \
    up

docker run --rm \
    -v $COMPILE_FOLDER:/go/src/github.com/SUGUS-GNULinux/minolobot \
    -w /go/src/github.com/SUGUS-GNULinux/minolobot \
    golang:1.9 \
    go build -o minolobot_launch main.go


echo "_____________ Eliminando despliegue actual _____________"

dockerStopAndRm $ENV_NAME-$BRANCH


echo "_____________ Preparando archivos _____________"

rm -r "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"
mkdir -p "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"
cp -r $COMPILE_FOLDER/* "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"

rm -rf $COMPILE_FOLDER

# Permisos de ejecución
chmod 777 "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/minolobot_launch"


echo "_____________ Desplegando contenedores de $ENV_NAME - $BRANCH _____________"

docker run -d --name $ENV_NAME-$BRANCH \
    --restart=always \
    -v "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/":/usr/src/minolobot \
    -v "$SUGUS_PRIV_CONFIG_PATH/$ENV_NAME-$BRANCH/token":/usr/src/minolobot/datafiles/token \
    -v "$SUGUS_PRIV_CONFIG_PATH/$ENV_NAME-$BRANCH/database.db":/usr/src/minolobot/minolobot.db \
    -w /usr/src/minolobot \
    golang:1.9 \
    ./minolobot_launch

echo "Listo"
