#!/bin/env bash

# a safe wrapper of perlstrip

# try to execute perlstrip
timeout 10 perlstrip -o "/tmp/perlstrip.$$" -v "$1" || exit 0

# syntax check
if /opt/bin/perl -c "/tmp/perlstrip.$$"; then
    # replace it by stripped version
    mv "/tmp/perlstrip.$$" "$1" || exit 1
else
    echo "fail to perlstrip $1" >&2
fi
