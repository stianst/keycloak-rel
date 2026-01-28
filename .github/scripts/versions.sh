#!/bin/bash -e

org=$1
branch=$2

stream="$( echo "$branch" | cut -d '/' -f 2 )"

LAST_TWO_VERSIONS=($(gh release -R $org/keycloak list --json tagName | jq -r '.[].tagName' | grep -v "nightly" | sort -V -r | head -n 2))

last_version="${LAST_TWO_VERSIONS[0]}"
previous_version="${LAST_TWO_VERSIONS[1]}"

if [[ "$last_version" == "$stream"* ]]; then
  last_micro=$(echo $last_version | cut -d '.' -f 3)
  next_micro=$((last_micro++))
  next_version="$stream"
else
  next_version="$stream.0"
fi

echo "branch=$branch"
echo "stream=$stream"
echo "last-version=$last_version"
echo "next-version=$next_version"
echo "previous-version=$previous_version"