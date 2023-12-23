#!/bin/bash

set -e
set -o pipefail
set -u

cd alex; poetry install

echo "The artifact appears functional!"
