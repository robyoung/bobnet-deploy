#!/bin/bash

APP=$1

[ -f "apps/$APP/VERSION" ] || { echo "No version file"; exit 2; }

PREVIOUS_VERSION=$(cat "apps/$APP/VERSION")
echo "Previous version is $PREVIOUS_VERSION"
echo "Current version is $(expr $PREVIOUS_VERSION + 1)"
VERSION=$(printf "%03d" $(expr $PREVIOUS_VERSION + 1))

docker build -t robyoung/$APP:$VERSION ./apps/$APP
docker tag robyoung/$APP:$VERSION robyoung/$APP:latest
docker push robyoung/$APP:$VERSION
docker push robyoung/$APP:latest

echo $VERSION > "apps/$APP/VERSION"

sed -e "s/$PREVIOUS_VERSION/$VERSION/g" -i '.bak' stacks/$APP.yml
