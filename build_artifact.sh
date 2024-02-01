#!/bin/bash

set -e
set -o pipefail
set -u

TAG_ALEX=$1
TAG_THRP=$2
ARTIFACT_NAME="alex-artifact-${TAG_ALEX}-${TAG_THRP}-$(date -u +%Y%m%dT%H%MZ).zip"

mkdir -p artifact/img
dot -Tsvg graph.dot > artifact/img/graph.svg

(
    cd artifact

    git clone https://github.com/stephenswat/alex.git

    (
        cd alex
        git checkout -q ${TAG_ALEX}
        rm -rf .git
        rm README.md
        sed -i -e 's/^readme = \"README.md\"$//g' pyproject.toml
        sed -i -e 's/\"Stephen Nicholas Swatman <stephen@v25.nl>\"//g' pyproject.toml
    )

    git clone https://github.com/stephenswat/morton-throughput.git

    (
        cd morton-throughput
        git checkout -q ${TAG_THRP}
        rm -rf .git
        rm README.md
        sed -i -e 's/^readme = \"README.md\"$//g' pyproject.toml
        sed -i -e 's/\"Stephen Nicholas Swatman\"//g' pyproject.toml
    )

    (! grep -iR "stephen" .)
    (! grep -iR "swatman" .)
)

zip -r $ARTIFACT_NAME artifact

(
    cd artifact
    rm -rf alex
    rm -rf morton-throughput
    rm -rf img
)

echo "Artifact $ARTIFACT_NAME built succesfully!"
