PREFIX=${PREFIX:=$HOME/.local}

download_url_to() {
	typeset url=$1
	typeset filename=$2

	if test -f $filename ; then
		echo "Using $filename." >&2
	else
		curl -o $filename $url >&2
	fi
	echo "$filename"
}
add_lib_to_system() {
	typeset prefix=$1
	typeset proj=$2

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

register_lib() {
	typeset path=$1
	typeset conf=$2
	echo "$path" > proj.conf

	sudo mv proj.conf $conf
	sudo ldconfig
}
