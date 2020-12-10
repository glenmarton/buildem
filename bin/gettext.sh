#!/bin/sh
BIN=$(readlink -f ${0%/*})
TOP=${BIN%/*}

#
#   f u n c t i o n s
#
clone_repo() {
	typeset repo=$1
	typeset proj=${1%%*/}
	proj=${proj%.*}

	if ! test -d $TOP/$proj
	then
		git clone $repo
	fi
}
checkout_latest_git_tag() {
	TAG=$(git tag | awk -f $BIN/latest_tag.awk)
	git checkout "$TAG" >/dev/null
}


#
#   s c r i p t
#
clone_repo https://git.savannah.gnu.org/git/gettext.git

cd $TOP/gettext

checkout_latest_git_tag
