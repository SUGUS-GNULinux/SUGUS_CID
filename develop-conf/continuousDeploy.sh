#!/bin/bash 

URL_REPO="https://github.com/ISSPUS/Shipmee.git"
BRANCH="develop"

ENV_NAME="Shipmee"
URL_VIRTUAL_HOST="dev.shipmee.duckdns.org"

PATH_ROOT="/home/core/Shipmee_CID_Workspace"
CONFIG_ROOT="/home/core/Shipmee_CID"

CONF_TOMCAT_SERVER="$CONFIG_ROOT/$BRANCH-conf/tomcat7/server.xml"

MYSQL_PROJECT_ROUTE="localhost"
MYSQL_ROOT_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32)"

RANDOM_FOLDER_NAME="$(date +%s | sha256sum | base64 | head -c 4)"


mkdir -p $PATH_ROOT

echo "_____________ Generando WAR _____________"

COMPILE_FOLDER="$PATH_ROOT/war_generation/$RANDOM_FOLDER_NAME"

mkdir -p "$COMPILE_FOLDER"

git clone $URL_REPO $COMPILE_FOLDER

cd $COMPILE_FOLDER

git checkout $BRANCH

docker run --rm \
    -v $COMPILE_FOLDER:/root \
    -v "$PATH_ROOT/war_generation/.m2":/root/.m2 \
    -w /root \
    maven:3-jdk-8-alpine \
    mvn clean compile war:war

echo "Persistiendo war y otros archivos necesarios"

find "$COMPILE_FOLDER/target/" -follow -name *.war -exec cp {} "$PATH_ROOT/Shipmee-$BRANCH.war" \;
# mv -f $COMPILE_FOLDER/target/Shipmee-*.war $PATH_ROOT/Shipmee-$BRANCH.war
mv -f $COMPILE_FOLDER/initialize.sql $PATH_ROOT/initialize-$BRANCH.sql


echo "_____________ Desplegando $ENV_NAME - $BRANCH _____________"


echo "Eliminando despliegue actual"

ContainerId1=`docker ps -qa --filter "name=$ENV_NAME-$BRANCH-mysql"`
if [ -n "$ContainerId1" ]
then
	echo "Stopping and removing existing $ENV_NAME-$BRANCH-mysql container"
	docker stop $ContainerId1
	docker rm -v $ContainerId1
fi

ContainerId2=`docker ps -qa --filter "name=$ENV_NAME-$BRANCH-tomcat"`
if [ -n "$ContainerId2" ]
then
	echo "Stopping and removing existing $ENV_NAME-$BRANCH-tomcat container"
	docker stop $ContainerId2
	docker rm -v $ContainerId2
fi


echo "Preparando archivos para despliegue"

rm -r "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"

mkdir -p "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/webapps/"

# WAR
cp $PATH_ROOT/Shipmee-$BRANCH.war $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/webapps/ROOT.war

# SQL
cp $PATH_ROOT/initialize-$BRANCH.sql $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/populate.sql


echo "Desplegando contenedores para $ENV_NAME - $BRANCH"

docker run --name $ENV_NAME-$BRANCH-mysql \
    -v "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/populate.sql":/home/user/populate.sql \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
    --restart=always \
    -d mysql:5.7 \
    --bind-address=0.0.0.0


echo "$ENV_NAME-mysql creado !"

sleep 20

docker exec $ENV_NAME-$BRANCH-mysql \
    bash -c "exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < /home/user/populate.sql"

echo "$ENV_NAME-mysql populado !"

sleep 20

docker exec $ENV_NAME-$BRANCH-mysql \
    bash -c "echo "Europe/Madrid" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata"


docker restart $ENV_NAME-$BRANCH-mysql

sleep 5

docker run --rm \
    --link $ENV_NAME-$BRANCH-mysql:$MYSQL_PROJECT_ROUTE \
    -v $COMPILE_FOLDER/:/root \
    -v "$PATH_ROOT/war_generation/.m2":/root/.m2 \
    -w /root \
    maven:3-jdk-8-alpine \
    mvn exec:java -Dexec.mainClass="utilities.PopulateDatabase"

rm -rf $COMPILE_FOLDER


docker run -d --name $ENV_NAME-$BRANCH-tomcat \
    --user root \
    --link $ENV_NAME-$BRANCH-mysql:$MYSQL_PROJECT_ROUTE \
    -v "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/webapps/":/usr/local/tomcat/webapps \
    -v "$CONF_TOMCAT_SERVER":/usr/local/tomcat/conf/server.xml \
    --restart=always \
    -e VIRTUAL_HOST="$URL_VIRTUAL_HOST" \
    -e VIRTUAL_PORT=8080 \
    -e "LETSENCRYPT_HOST=$URL_VIRTUAL_HOST" \
    -e "LETSENCRYPT_EMAIL=shipmee.contact@gmail.com" \
    tomcat:7

docker exec $ENV_NAME-$BRANCH-tomcat \
    bash -c "echo "Europe/Madrid" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata"

echo "Aplicación desplegada en https://$URL_VIRTUAL_HOST"
 
