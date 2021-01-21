#!/bin/sh
BIN=${0%/*}
. $BIN/include.sh

#
#   f u n c t i o n s
#
download_latest_source() {
	typeset tarball=$(curl https://www.openssl.org/source/ | \
			sed -n 's/.*\(openssl-[0-9.]\+[a-z].*\.tar\.gz\).*/\1/p')
	typeset url="https://www.openssl.org/source/$tarball"

	download_url_to "$url" "$HOME/Downloads/$tarball"
}

build_and_install() {
	cd openssl-*
	./config --prefix=$PREFIX
	make all test
	make install || sudo make install
	cd - >/dev/null 2>&1
}
update_ld_so_conf() {
	sudo cat <<-EOF  >/etc/ld.so.conf.d/openssl-x86_64.conf
	$PREFIX/lib
	EOF
	sudo ldconfig
}

#
#   s c r i p t
#    b o d y
#
PREFIX=${PREFIX:=$HOME/.local/openssl}
TARBALL=$(download_latest_source)

tar -xzf $TARBALL

build_and_install "$TARBALL"
add_lib_to_system $PREFIX compiled
