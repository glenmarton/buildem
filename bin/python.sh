#!/bin/sh
BIN=${0%/*}
. $BIN/include.sh

#
#   f u n c t i o n s
#
install_dependencies_for_compiling() {
	if ! rpm -q zlib-devel >/dev/null 2>&1
	then
		sudo yum install -y zlib-devel
	fi
}
get_latest_version() {
	curl https://www.python.org/downloads/source/ | sed -n \
		's/.*Latest Python 3 Release - Python \([.0-9]\+\)<\/a>.*/\1/p'
}
download_source_of() {
	typeset version=$1
	typeset tarball="Python-$version.tgz"
	typeset url="https://www.python.org/ftp/python/$version/$tarball"

	download_url_to "$url" "$HOME/Downloads/$tarball"
}
build_and_install() {
	typeset directory="$1"
	cd $directory
	./configure --prefix=$PREFIX
	make all install
	cd - >/dev/null 2>&1
}

#
#   S c r i p t
#    B o d y
#
PREFIX=${PREFIX:=$HOME/.local}
install_dependencies_for_compiling

VERSION=$(get_latest_version)
TARBALL=$(download_source_of $VERSION)

if true
then
	echo "PREFIX=$PREFIX"
else
tar -xzf $TARBALL

build_and_install "Python-$VERSION"
fi

