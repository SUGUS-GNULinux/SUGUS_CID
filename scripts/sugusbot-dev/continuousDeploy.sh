#!/bin/bash

CONFIG_ROOT="/home/core/SUGUS_CID"

## Include dependencies

source $CONFIG_ROOT/commonDependencies/DockerUtils.sh


## Defining variables

source $CONFIG_ROOT/commonDependencies/variables.sh

ENV_NAME="sugusbot"
BRANCH="dev"

echo "_____________ Eliminando despliegue actual _____________"

dockerStopAndRm $ENV_NAME-$BRANCH


echo "_____________ Preparando archivos _____________"

rm -r "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"
cp -r $REPO_PATH/$ENV_NAME-$BRANCH/* "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"


echo "_____________ Desplegando contenedores de $ENV_NAME - $BRANCH _____________"


docker run -d --name $ENV_NAME-$BRANCH \
    --restart=always \
    -v "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/":/usr/src/sugusbot \
    -v "$SUGUS_PRIV_CONFIG_PATH/sugusbot-dev/config.ini":/usr/src/sugusbot/myconfig.ini \
    -w /usr/src/sugusbot \
    python:3 \
    bash -c "pip install -r requirements.txt && python sugusbot.py"

dockerTimeZoneGeneric $ENV_NAME-$BRANCH

echo "Listo"
