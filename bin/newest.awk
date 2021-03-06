#PURPOSE: Pipe `git tag` to this script for most recent tag in the project.
BEGIN {
	FS="."
	max=0
	tag=""
}
{
	maj=$1
	sub(/v/,"",maj)
	bug=$3
	sub(/[ 	]\+.*/,"",bug)
	sum=maj*10000 + $2*100 + $3

	if(max < sum) {
		max=sum
		tag=$0
	}
}
END {
	print tag
}
