#!/bin/bash

set -e
set -o pipefail
set -u

TEMP_DIR=$(mktemp -d)
RAND_NAME=$(echo $RANDOM | md5sum | head -c 10; echo;)

echo "Testing artifact $1 in $TEMP_DIR"

cp $1 $TEMP_DIR

(
    cd $TEMP_DIR
    tar -xzvf $(basename $1)
    cd artifact
    docker build -t alex_artifact_$RAND_NAME .
    docker run -it alex_artifact_$RAND_NAME bash -c "cd alex; poetry install"
)
