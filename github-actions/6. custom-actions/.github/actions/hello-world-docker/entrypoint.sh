#!/bin/bash

set -e

echo "Hello $1 from Docker!"

time=$(date)
echo "time=$time" >> $GITHUB_OUTPUT

echo "Current time: $time"
