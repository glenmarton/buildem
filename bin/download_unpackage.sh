#!/bin/bash

#
#   f u n c t i o n s
#
URL_has_tarball() {
	FN=$1

	if [[ "$FN" =~ '.gz' ]] ; then
		echo "Tarball compressed by gzip." >&2
	elif [[ "$FN" =~ '.bz2' ]] ; then
		echo "Tarball compressed by bzip2." >&2
	elif [[ "$FN" =~ '.xz' ]] ; then
		echo "Tarball compressed by xz utils." >&2
	else
		echo "Using URL $FN." >&2
		return 1
	fi
	return 0
}

find_download_filename() {
	FILENAME=$($BIN/scrape_latest.sh $URL | head -n1)
	if [[ "$FILENAME" =~ 'http' ]] ; then
		FILENAME=${FILENAME#*/}
	fi
	echo "$FILENAME"
}

download_file() {
	typeset url="$1/${2##*/}"
	typeset filename="$2"

	if filename_is_a_url "$filename"
	then
		url=$filename
		filename="${filename%%*/}"
	fi
	test $DEBUG && echo "Download $url to $filename" >&2

	if ! test -f $filename
	then
		curl "$url" > $filename
	fi
}

filename_is_a_url() {
	typeset filename=$1
	[[ "$filename" =~ 'http' ]]
}

#
#   s c r i p t
#
BIN=${0%/*}
URL=$1

if URL_has_tarball $URL
then
	FILENAME=${URL##*/}
	URL=${URL%/*}
else
	find_download_filename $URL
fi

mkdir -p ./downloads >/dev/null
FILENAME="./downloads/$FILENAME"

download_file "$URL" "$FILENAME"

tar xzf $FILENAME
