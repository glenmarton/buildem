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
