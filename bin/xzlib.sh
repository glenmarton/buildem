#!/bin/sh
BIN=$(readlink -f ${0%/*})
TOP=${BIN%/*}

#
#   f u n c t i o n s
#
checkout_latest_git_tag() {
	TAG=$(git tag | awk -f $BIN/latest_tag.awk)
	git checkout "$TAG" >/dev/null
}


#
#   s c r i p t
#
if ! test -d $TOP/xz
then
	git clone git clone https://git.tuk@ni.org/xz.git
fi

cd $TOP/xz
checkout_latest_git_tag

./autogen.sh --no-po4a
./configure --prefix=$HOME/.local
make all install
