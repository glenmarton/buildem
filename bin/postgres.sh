#!/bin/sh
BIN=${0%/*}
. $BIN/include.sh

#
#   f u n c t i o n s
#
install_dependencies_for_compiling() {
	if ! rpm -q readline-devel >/dev/null 2>&1
	then
		sudo yum install -y readline-devel
	fi
}
get_latest_version() {
	curl https://www.postgresql.org/ftp/source/ | sed -n \
		's/.*v\([0-9]\+.[0-9]\+\.\?[0-9]*\)<\/a>.*/\1/p' | head -n1
}
download_source_of() {
	typeset version=$1
	typeset tarball="postgresql-$version.tar.gz"
	typeset url="https://ftp.postgresql.org/pub/source/v$version/$tarball"

	download_url_to "$url" "$HOME/Downloads/$tarball"
}

build_and_install() {
	typeset tarball=$1
	typeset dest=$PREFIX/pgsql

	cd $(tarball_to_directory $tarball)

	mkdir -p $dest
	build_install_i686 $dest
	build_install_x86_64 $dest
	add_PSQL_PATH_to_rcfiles $dest $HOME/.*shrc
	make_pg_config_visible_to_OS $dest/x86_64/bin/pg_config

	cd - >/dev/null 2>&1
}
tarball_to_directory() {
	typeset tarball=${1%.tar.gz}
	echo "${tarball##*/}"
}
build_install_i686() {
	typeset dest=$1
	export CFLAGS=-m32
	./configure --prefix=$dest/i686
	make clean all install
	unset CFLAGS
}
build_install_x86_64() {
	typeset dest=$1
	./configure --prefix=$dest/x86_64
	make clean all install
}
add_PSQL_PATH_to_rcfiles() {
	typeset PSQL_PATH=$1
	for fname in $@
	do
		sed -i '/export PSQL_PATH/d' $fname
		echo "export PSQL_PATH=$PSQL_PATH" >> $fname
	done
}
make_pg_config_visible_to_OS() {
	# This is a work around for a bug with `bundle config`. If the Linux OS can find
	#`pc_config`, i.e. `which pg_config` comes back with an answer, then bundle will
	# automatically build do_postgres gem without any problems.
	# I got the idea from
	# https://stackoverflow.com/questions/21079820/how-to-find-pg-config-path
	# half way down with the score of 8 dated Oct 28, 2015.
	typeset target=$1
	typeset link=/usr/local/bin/pg_config
	if test -f $link
	then
		echo "Skipping: $target already exists."
	elif ln -f -s $target $link
	then
		echo "Success: $target generated."
	elif sudo ln -f -s $target $link
	then
		echo "Success: $target generated."
	else
		echo "Failed: No $target exists."
	fi
}

#
#   s c r i p t
#    b o d y
#
PREFIX=${PREFIX:=$HOME/.opt}
install_dependencies_for_compiling

VERSION=$(get_latest_version)
TARBALL=$(download_source_of $VERSION)

echo "Untarring $TARBALL>"
set -x
tar -xzf $TARBALL
build_and_install "$TARBALL"

