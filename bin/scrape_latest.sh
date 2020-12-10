#!/bin/sh
set -x
URL=$1
echo "Using URL $URL." >&2
if ! test -f ftplist.html
then
	curl "$URL" > ftplist.html
fi
sed -n 's/.*<a href=\"\([^"]*\)\".*/\1/p' ftplist.html \
	| grep -- '[0-9]\{1,3\}\.[.0-9]\+\.tar.gz$' >release_list.txt
VERSION=$(sed 's/.*-\([.0-9]\+\)\..*/\1/' release_list.txt | awk -f bin/newest.awk)
grep "$VERSION" release_list.txt && rm -f release_list.txt ftplist.html
