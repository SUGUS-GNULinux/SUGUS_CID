#!/bin/bash

URL_REPO="https://github.com/Shipmee/Shipmee.git"
ENV_NAME="Shipmee"

PATH_ROOT="/home/core/Shipmee_CID_Workspace"
REPO_PATH="$PATH_ROOT/repositories"
PASSWORD_PATH="$PATH_ROOT/generatedPasswords.log"

SHIPMEE_PRIV_CONFIG_PATH="/home/core/Shipmee_Priv_Config/deploy"

DOCKERS_LOGS_PATH="$PATH_ROOT/old_logs"

mkdir -p $PATH_ROOT

MYSQL_PROJECT_ROUTE="localhost"
MYSQL_ROOT_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32)"

RANDOM_FOLDER_NAME="$(date +%s | sha256sum | base64 | head -c 4)"
