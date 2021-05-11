#!/bin/sh
BIN=$(readlink -f ${0%/*})
TOP=${BIN%/*}
PREFIX=${PREFIX:=$HOME/.local}

#
#   f u n c t i o n s
#
get_download_link_from() {
	typeset url=$1
	echo -n "$url"
	curl $url 2>/dev/null | grep -m1 '<th.*href.*\.gz' | \
		sed -n 's/.*files\/\(.*\)\/download\"/\1/p'
}
download_source() {
	typeset url=$1
	typeset SOURCE_TARBALL="${url##*/}"

	if [ ! -f ~/Downloads/$SOURCE_TARBALL ]
	then
		wget $url
		mv ${url##*/} ~/Downloads
	fi
	echo "$HOME/Downloads/$SOURCE_TARBALL"
}
unzip_file() {
	typeset tarball=$1
	typeset xzdir=${tarball%.tar*}
	xzdir=${xzdir##*/}

	if [ ! -d $xzdir ]
	then
		tar -xzf $tarball
	fi

	echo "$xzdir"
}

#
#   s c r i p t
#
URL=$(get_download_link_from 'https://sourceforge.net/projects/lzmautils/files/')

TARBALL=$(download_source $URL)

DIR=$(unzip_file $TARBALL)
cd $DIR

if [ "$1" = '-t' ]
then
	cat <<-EOF
	URL=$URL
	TARBALL=$TARBALL
	DIR=$DIR
	EOF
else
	./configure --prefix=$PREFIX
	make all
	make install || sudo make install
fi
