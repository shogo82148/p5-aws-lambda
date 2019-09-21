#!/bin/env bash

# a safe wrapper of perlstrip

# try to execute perlstrip
timeout 10 perlstrip -o "/tmp/perlstrip.$$" -v "$1" || exit 0

# replace it by stripped version
mv "/tmp/perlstrip.$$" "$1" || exit 1
