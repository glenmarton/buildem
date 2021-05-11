#!/bin/sh
BIN=$(readlink -f ${0%/*})
TOP=${BIN%/*}
PREFIX=${PREFIX:=$HOME/.local}

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
if ! test -d $TOP/xz*
then
	typeset URL=$(curl https://sourceforge.net/projects/lzmautils/files/ | \
		grep -m1 -A1 '<tr title="xz-.*\.gz' | sed -n 's/.*href="\(.*\)"$/\1/p')
	curl -o ~/Downloads/xz.tar.gz $URL
	tar -fxz ~/Downloads/xz.tar.gz
fi

cd $TOP/xz*

./configure --prefix=$PREFIX
make all
make install || sudo make install
