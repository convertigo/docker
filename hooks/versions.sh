#!/bin/bash

export C8O_LATEST=7.4.3

# SOURCE_BRANCH: the name of the branch or the tag that is currently being tested.
# SOURCE_COMMIT: the SHA1 hash of the commit being tested.
# COMMIT_MSG: the message from the commit being tested and built.
# DOCKER_REPO: the name of the Docker repository being built.
# DOCKER_TAG: the Docker repository tag being built.
# IMAGE_NAME: the name and tag of the Docker repository being built. (This variable is a combination of DOCKER_REPO:DOCKER_TAG.)

verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

export C8O_VERSION=$(echo $DOCKER_TAG | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
export C8O_MODE=$(echo $DOCKER_TAG | sed 's/\([^0-9.]*\)-.*/\1/')

if [ "$C8O_VERSION" = "" ]; then
    echo "version needed"
    exit 1
fi

if verlte 7.4.2 $C8O_VERSION; then
    export C8O_BASE_VERSION=7.4.2
elif verlte 7.4.0 $C8O_VERSION; then
    export C8O_BASE_VERSION=7.4.0
elif verlte 7.3.0 $C8O_VERSION; then
    export C8O_BASE_VERSION=7.3.0
else
    echo "don't build under 7.3.0 version"
    exit 1
fi

if [ "$C8O_MODE" = "mbaas" ]; then
    export C8O_PROC=64
elif [ "$C8O_MODE" = "web-connector" ]; then
    export C8O_PROC=32
else
    echo "unknow $C8O_MODE mode"
    exit 1
fi
