#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

read -p "Enter the URL from email: " https://download2.llamameta.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7InVuaXF1ZV9oYXNoIjoiOTg3bDN1NmN0ZHljZWFoYXN2Y2JjbjZsIiwiUmVzb3VyY2UiOiJodHRwczpcL1wvZG93bmxvYWQyLmxsYW1hbWV0YS5uZXRcLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3MDczNzMwNzd9fX1dfQ__&Signature=vD6AXJzwHzEqVdZ486sedp%7EPh4e7X5RoQdcUPmtd89A6qf6bh4GcbBRXy07L-4-Qmr3LWnlbfQLd2N78otMWWqlpR3z05-PfMttw-6WbTdvHT2SK9%7EigSDbsUEiIp5k-entC%7EBqaIb4BXFt76vAtJC-u8NUybaTXz0d27tFdkHWlvobGI-rXWiBVY0GXKNEWyrUWkGvm%7EOPCfKLsSYGwSLUDcqn55RncD%7Efdrzl16h-GP8ZxrqioBJFhzIatuCPUZUbHRuFSy4susptw-WZwspQJrlvO5ByfSnocQPAluV0MFO9Tfn%7EsXmVujRBJxQLOJnDc1PpDGZDDOJZf0w6ZAw__&Key-Pair-Id=K15QRJLYKIFSLZ&Download-Request-ID=1195569648494805
echo ""
ALL_MODELS="7b,13b,34b,70b,7b-Python,13b-Python,34b-Python,70b-Python,7b-Instruct,13b-Instruct,34b-Instruct,70b-Instruct"
read -p "Enter the list of models to download without spaces ($ALL_MODELS), or press Enter for all: " MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE=$ALL_MODELS
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
wget --continue ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget --continue ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -O ${TARGET_FOLDER}"/USE_POLICY.md"

for m in ${MODEL_SIZE//,/ }
do
    case $m in
      7b)
        SHARD=0 ;;
      13b)
        SHARD=1 ;;
      34b)
        SHARD=3 ;;
      70b)
        SHARD=7 ;;
      7b-Python)
        SHARD=0 ;;
      13b-Python)
        SHARD=1 ;;
      34b-Python)
        SHARD=3 ;;
      70b-Python)
        SHARD=7 ;;
      7b-Instruct)
        SHARD=0 ;;
      13b-Instruct)
        SHARD=1 ;;
      34b-Instruct)
        SHARD=3 ;;
      70b-Instruct)
        SHARD=7 ;;
      *)
        echo "Unknown model: $m"
        exit 1
    esac

    MODEL_PATH="CodeLlama-$m"
    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
    done

    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/tokenizer.model"
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5sum -c checklist.chk)
done
