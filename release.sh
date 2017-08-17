#!/bin/bash

# release 

if [[ $# -lt 3 ]]; then
  echo "usage: $(basename $0) previous-version new-version next-version" >&2
  exit 1
fi

previous_version=$1
version=$2
next_version=$3

function make_changelog ()
{
    echo -e "# Changelog\n\n## ${version} - $(date)\n\n${changelog}\n" 
}

echo ""
echo "Start release of $version, previous version is $previous_version"
echo ""
echo ""

## compile and run tests here....
git flow release start $version || exit 1

echo "{\"version\": \"$version\"}" > version.json

## get the changelog header
changelog=$(git --no-pager log --pretty="format:- %w(76,0,2)%s%w(76,2,2)%b" $previous_version..)

echo -n "*** Press ENTER to edit the CHANGELOG.md file:"  && read x
touch CHANGELOG.md
tail -n +2 CHANGELOG.md > temp && mv temp CHANGELOG.md
echo "$(make_changelog)" | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md
$EDITOR CHANGELOG.md

GIT_MERGE_AUTOEDIT=no
echo -n "Commiting Changelog and version.json ..." \
    && git add CHANGELOG.md version.json \
    && git commit -m "Updated Changelog and version.json for $version" \
    && echo -n "Releasing..." \
    && (export GIT_MERGE_AUTOEDIT=no; git flow release finish -m "release-$versino" $version) \
    && echo "*** Building Docker Image with tag $version ..." \
    && ./build-image.sh ${version} \
    && echo "*** Publisihing Docker Image with tag $version ..." \
    && ./push-image.sh ${version} \
    && echo "{\"version\": \"$next_version-dev\"}" > version.json \
    && git add version.json \
    && git commit -m "Prepare for the development cycle for version ${next_version}" \
    && echo "*** DONE!!!" \
    && echo "*** Now push to github. Don't forget the tags (push --tags)" \
