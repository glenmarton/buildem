#!/bin/sh
BIN=${0%/*}
URL=$1
PREFIX=${PREFIX:=$HOME/.opt}

SRCDIR=$($BIN/download_unpackage.sh $URL | sed 's/\.tar.*//')
echo "Source dir is $SRCDIR" >&2

if ! test -f $TARBALL
then
	curl "$URL/$FILENAME" > $TARBALL
fi

set -x
SRCDIR=${FILENAME%.tar.gz}
if ! test -d $SRCDIR
then
	tar xzf $TARBALL
fi

cd $SRCDIR
./configure --prefix=$PREFIX
make all install && rm -f ftplist.html
