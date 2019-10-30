#!/bin/sh
if [ -z "$1" ];then
	echo "$0 build|serve"
	exit 0
fi
if [ "$1" = "build" ];then
	rm -rvf _site
fi
bundle exec jekyll $1
