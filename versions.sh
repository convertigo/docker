#!/bin/bash

## split the DOCKER_TAG to another environment variables
## expected DOCKER_TAG : [mbaas|web-connector]-x.y.z(_tag)-v12345-(t7.0.42)(*)


# SOURCE_BRANCH: the name of the branch or the tag that is currently being tested.
# SOURCE_COMMIT: the SHA1 hash of the commit being tested.
# COMMIT_MSG: the message from the commit being tested and built.
# DOCKER_REPO: the name of the Docker repository being built.
# DOCKER_TAG: the Docker repository tag being built.
# IMAGE_NAME: the name and tag of the Docker repository being built. (This variable is a combination of DOCKER_REPO:DOCKER_TAG.)


echo_and_run() {
    echo "\$ $@"
    "$@"
}

## check if force a tomcat version

TOMCAT_VERSION=$(echo $DOCKER_TAG | sed -n 's/.*-t\([0-9.]*\).*/\1/p')

if [ "$TOMCAT_VERSION" != "" ]; then
    TOMCAT_MAJOR=$(echo $TOMCAT_VERSION | sed -n 's/\([0-9]*\)\..*/\1/p')
    export FORCE_TOMCAT_ARGS="--build-arg TOMCAT_VERSION=$TOMCAT_VERSION --build-arg TOMCAT_MAJOR=$TOMCAT_MAJOR"
fi


## switch the Dockerfile name using the convertigo mode (mbaas or web-connector)

export CONVERTIGO_MODE=$(echo $DOCKER_TAG | sed -n 's/\([^0-9.]*\)-.*/\1/p')

if [ "$CONVERTIGO_MODE" = "mbaas" ]; then
    export DOCKER_FILE="Dockerfile"
elif [ "$CONVERTIGO_MODE" = "web-connector" ]; then
    export DOCKER_FILE="Dockerfile-$CONVERTIGO_MODE"
else
    echo "unknow '$CONVERTIGO_MODE' mode"
    exit 1
fi


## extract the convertigo version x.y.z(_tag)

export CONVERTIGO_VERSION=$(echo $DOCKER_TAG | sed -n 's/[^0-9.]*-\([^\-]*\)-.*/\1/p')

if [ "$CONVERTIGO_VERSION" = "" ]; then
    echo "version needed"
    exit 1
fi


## extract the convertigo revision 12345

export CONVERTIGO_REVISION=$(echo $DOCKER_TAG | sed -n 's/.*-v\([0-9]*\).*/\1/p')

if [ "$CONVERTIGO_REVISION" = "" ]; then
    echo "revision needed"
    exit 1
fi


## check if this build is requested as latest (end with _)

export CONVERTIGO_LATEST=$(echo $DOCKER_TAG | sed -n 's/.*_$/yes/p')