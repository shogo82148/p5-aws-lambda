#!/usr/bin/env bash

# a safe wrapper of perlstrip

# try to execute perlstrip
timeout 60 perlstrip -c -o "/tmp/perlstrip.$$" -v "$1" || exit 0

# replace it by stripped version
set -e
mv -f "/tmp/perlstrip.$$" "$1"
