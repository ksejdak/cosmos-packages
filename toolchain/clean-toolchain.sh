#!/bin/bash
# $1 - toolchain install path

if [ -z "$1" ]; then
    echo "No toolchain install path provided! Abort."
    exit 1
fi

BUILD_ROOT="$1"
cd "${BUILD_ROOT}"
find . ! -name . -maxdepth 1 -type d -exec rm -rf {} +
cd -

exit 0
