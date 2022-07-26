if test -d $HOME/downloads
then
	echo "$HOME/downloads"
elif test -d $HOME/Downloads
then
	echo "$HOME/Downloads"
elif test -d downloads
then
	echo downloads
else
	mkdir downloads
	echo downloads
fi
