#!/bin/sh
cmd=
if [ -z "$1" ];then
	cmd="serve"
fi
if [ "$cmd" = "serve" ];then
	bundle exec jekyll serve
fi
