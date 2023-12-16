#!/bin/bash

set -e
set -o pipefail
set -u

TAG=$1
ARTIFACT_NAME="alex-artifact-${TAG}-$(date -u +%Y%m%dT%H%MZ).tar.gz"

(
    cd artifact

    git clone https://github.com/stephenswat/alex.git

    (
        cd alex
        git checkout -q ${TAG}
        rm -rf .git
        rm README.md
        sed -i -e 's/^readme = \"README.md\"$//g' pyproject.toml
        sed -i -e 's/\"Stephen Nicholas Swatman <stephen@v25.nl>\"//g' pyproject.toml
    )

    (! grep -iR "stephen" .)
    (! grep -iR "swatman" .)
)

tar -czvf $ARTIFACT_NAME artifact

(
    cd artifact
    rm -rf alex
)

echo "Artifact $ARTIFACT_NAME built succesfully!"
