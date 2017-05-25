#!/bin/bash

PATH_ROOT="/home/core/SUGUS_CID_Workspace"
REPO_PATH="$PATH_ROOT/repositories"
PASSWORD_PATH="$PATH_ROOT/generatedPasswords.log"

SUGUS_PRIV_CONFIG_PATH="/home/core/SUGUS_CID_Priv_Config/deploy"

DOCKERS_LOGS_PATH="$PATH_ROOT/old_logs"

mkdir -p $PATH_ROOT

RANDOM_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32)"

RANDOM_FOLDER_NAME="$(date +%s | sha256sum | base64 | head -c 4)"
