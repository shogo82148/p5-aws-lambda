#!/usr/bin/env bash

ZIP=$1
aws s3 cp "$ZIP" s3://
