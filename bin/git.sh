#!/bin/sh
BIN=${0%/*}
URL=https://mirrors.edge.kernel.org/pub/software/scm/git/
FILENAME=$($BIN/scrape_latest.sh $URL | head -n1)
curl $URL/$FILENAME -o ~/Downloads/$FILENAME
