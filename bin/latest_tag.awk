#PURPOSE: Pipe `git tag` to this script for most recent tag in the project.
BEGIN {
	FS="."
	max=0
	tag=""
}
/\.[0-9]+$/ {
	maj=$1
	sub(/v/,"",maj)
	min=$2
	bug=$3
	sub(/[ 	]\+.*/,"",bug)
	sum=maj*10000 + $2*100 + $3

	#print "max="max", sum="sum",  maj="maj", min="min", bug="bug
	if(max < sum) {
		max=sum
		tag=$0
	}
}
END {
	print tag
}
