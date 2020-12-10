s/^<pre>/#!\/bin\/sh/
/^<\/pre>/d
s/localperl/.local/
s#.*">\(.*\)/\([^/]*\)</a>#curl -o \2 \1\/\2#
s#^    ##
