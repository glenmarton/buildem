#!/bin/sh

#   f u n c t i o n s
tweak_libs_so_python_finds_them() {

	pretend_libxz5_is_installed

	help_python_find_pg_config
}
comment_out_pragma_lines_for_old_compiler() {
	if gcc --version | grep -qs '4.4.7'
	then
		sed -i '/pragma GCC diagnostic/ s%#%// #%' ./Modules/_ctypes/callbacks.c
		sed -i '/pragma GCC diagnostic/ s%#%// #%' ./Modules/_zoneinfo.c
	fi
}

pretend_libxz5_is_installed() {
	if test -f /usr/lib/liblzma.so && rpm -q xz-4.999.9 >/dev/null
	then
		sudo ln -fs /usr/lib/liblzma.so /usr/lib/liblzma.so.5
	elif test -f /usr/lib64/liblzma.so.5
	then
		# looks good
		true
	elif ! test -f /usr/lib/liblzma.so
	then
		echo "ERROR: Missing liblzma, install liblzma on server." >&2
		exit 3
	fi
}

help_python_find_pg_config() {
	typeset pgdir=$(path_to_latest_version_of_postgres)
	typeset pgconfig="$pgdir/$(uname -m)/bin/pg_config"

	if test -f $pgconfig
	then
		sudo ln -fs $pgconfig /usr/bin
	else
		echo "ERROR: Couldn't find pg_config to compile postgres." >&2
		exit 3
	fi
}

path_to_latest_version_of_postgres() {
	ls -d /usr/pgsql* | \
		awk -F- '{print $2" "$0}' | \
		sort -n | \
		tail -n1 | \
		cut -d' ' -f2
}

#   s c r i p t
PREFIX=$1
PREFIX=${PREFIX:=$HOME/.opt}

tweak_libs_so_python_finds_them

comment_out_pragma_lines_for_old_compiler

./configure --enable-optimizations --prefix=$PREFIX --with-openssl=$PREFIX
