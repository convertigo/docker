#!/bin/bash

# SOURCE_BRANCH: the name of the branch or the tag that is currently being tested.
# SOURCE_COMMIT: the SHA1 hash of the commit being tested.
# COMMIT_MSG: the message from the commit being tested and built.
# DOCKER_REPO: the name of the Docker repository being built.
export DOCKER_REPO=convertigo/convertigo

# DOCKER_TAG: the Docker repository tag being built.
export DOCKER_TAG=$1

# IMAGE_NAME: the name and tag of the Docker repository being built. (This variable is a combination of DOCKER_REPO:DOCKER_TAG.)
export IMAGE_NAME=$DOCKER_REPO:$DOCKER_TAG

(\
    cd -P $(dirname $0);\
    . hooks/build \
    && . hooks/post_push\
)