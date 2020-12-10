#!/bin/sh
BIN=${0%/*}
URL=$1
PREFIX=${PREFIX:=$HOME/.opt}

FILENAME=$($BIN/scrape_latest.sh $URL | head -n1)

TARBALL=$HOME/Downloads/$FILENAME

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
