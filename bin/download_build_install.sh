#!/bin/sh

#
#   f u n c t i o n s
#
generate_configure_script() {
	if test -x configure
	then
		test $DEBUG && echo 'Configure exists' >&2
	elif test -x ./autogen.sh
	then
		./autogen.sh
	else
		if ! autoreconf
		then
			test $DEBUG && echo 'No way to generate configure'
			exit 2
		fi
	fi
}

#
#   s c r i p t
#
BIN=${0%/*}
URL=$1
PREFIX=${PREFIX:=$HOME/.opt}

SRCDIR=$($BIN/download_unpackage.sh $URL | sed 's/\.tar.*//')
echo "Source dir is $SRCDIR" >&2

if ! test -f $TARBALL
then
	curl "$URL/$FILENAME" > $TARBALL
	cd $SRCDIR
	generate_configure_script
	./configure --prefix=$PREFIX
	make all install
fi
