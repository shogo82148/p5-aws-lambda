#!/usr/bin/env bash

set -uex

TAG=$1
cd /opt
unzip "/var/task/.perl-layer/dist/perl-$TAG-runtime.zip"
/opt/bin/cpanm --notest --no-man-pages Paws
