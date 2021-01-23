#!/bin/sh
BIN=$(readlink -f ${0%/*})
TOP=${BIN%/*}

#
#   f u n c t i o n s
#
get_project_src_dir_from() {
	typeset repo=$1
	typeset proj=${1##*/}
	proj="${proj%.git}"

	if ! test -d $proj
	then
		git clone $repo
	fi

	if test -d $proj
	then
		echo "$proj"
	else
		echo "No project found for $REPO." >&2
		exit 1
	fi
}
checkout_latest_git_tag() {
	TAG=$(git tag | awk -f $BIN/latest_tag.awk)
	if [ "$TAG" = '' ] ; then
		echo 'ERROR: No git tag found.' >&2
		exit 2
	fi
	git checkout "$TAG" 2>/dev/null
}
build_and_install_proj() {
	typeset prefix=$1
	if echo $prefix | grep i686 ; then
		export CFLAGS=-m32
	fi

	generate_configure_script
	if configure_project $DIR $prefix
	then
		make all install
	else
		echo "ERROR: Failed configuring $DIR." >&2
		exit 3
	fi

	if [ $CFLAGS ] ; then
		unset CFLAGS
	fi
}
add_lib_to_system() {
	typeset prefix=$1
	typeset proj=${prefix##*/}

	if test -d $prefix/lib ; then
		register_lib "$prefix/lib" "/etc/ld.so.conf.d/$proj.conf"

	elif test -d $prefix/x86_64/lib ; then
		register_lib "$prefix/x86_64/lib" "/etc/ld.so.conf.d/$proj-x86_64.conf"

	elif test -d $prefix/i686/lib ; then
		register_lib "$prefix/i686/lib" "/etc/ld.so.conf.d/$proj-i686.conf"
	else
		echo "$proj has no library to add."
	fi
}

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
configure_project() {
	typeset proj=$1
	typeset prefix=$2

	cd $proj
	if test -f $BIN/configure_$proj.sh
	then
		$BIN/configure_$proj.sh $prefix
	else
		./configure --prefix=$prefix
	fi
	return $?
}

register_lib() {
	typeset path=$1
	typeset conf=$2
	echo "$path" > proj.conf

	sudo cp proj.conf $conf
	sudo ldconfig
	rm -f proj.conf
}

#
#   s c r i p t
#
BIN=$(readlink -f $0)
BIN=${BIN%/*}
REPO=$1
REPO=${REPO:=https://github.com/madler/zlib.git}
DIR=$(get_project_src_dir_from $REPO)

cd $DIR
checkout_latest_git_tag

PREFIX=${PREFIX:=$HOME/.opt/${DIR##*/}}
build_and_install_proj $PREFIX

add_lib_to_system $PREFIX

cd - >/dev/null 2>&1
