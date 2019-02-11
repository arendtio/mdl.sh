#!/bin/sh

# https://stackoverflow.com/questions/2445198/get-seconds-since-epoch-in-any-posix-compliant-shell
PATH=`getconf PATH` awk 'BEGIN{srand();print srand()}'
