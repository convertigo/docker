#!/bin/bash

## simulate the docker-hub auto-build feature

# SOURCE_BRANCH: the name of the branch or the tag that is currently being tested.
# SOURCE_COMMIT: the SHA1 hash of the commit being tested.
# COMMIT_MSG: the message from the commit being tested and built.
# DOCKER_REPO: the name of the Docker repository being built.
# DOCKER_TAG: the Docker repository tag being built.
# IMAGE_NAME: the name and tag of the Docker repository being built. (This variable is a combination of DOCKER_REPO:DOCKER_TAG.)

if [[ "$1" != *":"* ]]; then
    echo "need a 'repo:tag' argument"
    exit 1
fi

export IMAGE_NAME=$1
export DOCKER_TAG=$(echo $1 | sed -n 's/.*:\(.*\)/\1/p')
export DOCKER_REPO=$(echo $1 | sed -n 's/\(.*\):.*/\1/p')

(\
    cd -P $(dirname $0);\
    . hooks/build \
    && . hooks/post_push\
)