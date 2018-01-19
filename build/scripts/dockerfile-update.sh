#!/bin/bash

OLD_MD5=build/vm.md5sum
OLD_VERSION=$(cat installer/VERSION |tr -d '\040\011\012\015')
OLD_HASH=$(cat "$OLD_MD5" |cut -d' ' -f1)
VMI_DOCKERFILE=installer/Dockerfile
VERSION_FILE=installer/VERSION

BIN_FILE="Rapid7Setup-Linux64.bin"
RELEASE_RESOURCE="ReleaseProduct-"
BASE_URL="http://download2.rapid7.com/download/InsightVM/"
VERSION_URL=$BASE_URL$BIN_FILE".version"

echo "Retrieving latest Version file"
VERSION_RESPONSE=$(curl -s -w STATUS:%{http_code} $VERSION_URL)
VERSION_BODY=$(echo $VERSION_RESPONSE |sed -e 's/STATUS\:.*//g' |tr -d '\040\011\012\015')
VERSION_STATUS=$(echo $VERSION_RESPONSE |sed -e 's/.*STATUS\://' |tr -d '\n')

if [ $VERSION_STATUS -eq 200 ]; then
    if [ $VERSION_BODY == $OLD_VERSION ]; then
        echo "No new version for update"
        exit 1
    fi
else
    echo "Failure when downloading version file"
    exit 1
fi

MD5_URL=$BASE_URL$RELEASE_RESOURCE$VERSION_BODY"/"$BIN_FILE".md5sum"

# Get MD5 information for comparison
RESPONSE=$(curl -s -w STATUS:%{http_code} $MD5_URL)
BODY=$(echo $RESPONSE |sed -e 's/STATUS\:.*//g')
STATUS=$(echo $RESPONSE |sed -e 's/.*STATUS\://' |tr -d '\n')

if [ $STATUS -eq 200 ]; then
  echo "Successful Download"
  VMFILE=$(printf "$BODY" |cut -d' ' -f2)
  if [ "$VMFILE" != "Rapid7Setup-Linux64.bin" ]; then
    exit 1
  fi
  NEW_HASH=$(printf "$BODY" |cut -d' ' -f1)
  if [ "$NEW_HASH" != "$OLD_HASH" ]; then
    echo "MD5SUM's are different, updating Dockerfile"
    printf "$BODY" > $OLD_MD5
    sed -i'' "s/$OLD_HASH/$NEW_HASH/g" $VMI_DOCKERFILE

    # Updating version file
    echo "Version file updated to: $VERSION_BODY"
    printf "$VERSION_BODY" > $VERSION_FILE

    # Let's update the download URL
    echo "Version in installer update to: $VERSION_BODY"
    sed -i'' "s/$OLD_VERSION/$VERSION_BODY/g" $VMI_DOCKERFILE

    echo "Dockerfile updated"
    git commit -a -m "Update Dockerfile and VERSION file for version: $VERSION_BODY"
    echo "git commit ran for master branch"
    echo "SUCCESS"
    exit 0
  else
    echo "No dockerfile to update, MD5 has not changed"
    exit 1
  fi
else
    echo "Failure when downloading MD5 file"
    exit 1
fi
